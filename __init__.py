
import os
import pulumi
import pulumi_docker as docker
import pulumi_gcp as gcp
import pulumi_kubernetes as k8s
from infra.docker import ImageBuilder
from pulumi import Config, export, get_project, get_stack, Output, ResourceOptions
import pulumi_random as prand
from typing import Mapping, Sequence

# https://github.com/weaveworks/grafanalib
# Used for building grafana dashboards dynamically
from grafanalib.core import (
    Alert, AlertCondition, Dashboard, Graph,
    GreaterThan, OP_AND, OPS_FORMAT, Row, RTYPE_SUM, SECONDS_FORMAT,
    SHORT_FORMAT, single_y_axis, Target, TimeRange, YAxes, YAxis
)

class IngestConfig():
    def __init__(self):
        pass

class IngestWorker(pulumi.ComponentResource):
    def __init__(self):
        super().__init__('IngestWorker', name, None, opts)
        self.path = os.path.dirname(os.path.abspath(__file__))

        # The sensor can be of any image format
        # which would allow for the tickerplant and
        # hdb to act as a sidecar therin
        self.stub = ImageBuilder(
               name="thorad/sensor",
               base_image="kdb32",
               prefix="sensor",
               path=self.path,
               skip_push=False,
               files=[
                "sensor.q"
               ],
               command="q sensor.q -t 100"
        )

class QenvConfig():
    def __init__(self):
        pass

class QenvWorker(pulumi.ComponentResource):
    def __init__(self):
        super().__init__('QenvWorker', name, None, opts)
        self.path = os.path.dirname(os.path.abspath(__file__))

        # The sensor can be of any image format
        # which would allow for the tickerplant and
        # hdb to act as a sidecar therin
        self.stub = ImageBuilder(
               name="thorad/sensor",
               base_image="kdb32",
               prefix="sensor",
               path=self.path,
               skip_push=False,
               files=[
                "sensor.q"
               ],
               command="q sensor.q -t 100"
        )


class KDBSensorSpec(object):
    def __init__(self):
        self.path = os.path.dirname(os.path.abspath(__file__))
        self.symfile = ""
        self.sensor_image = None

class KDBFullSensor(pulumi.ComponentResource):
    def __init__(self,
                 name:str = "bam",
                 opts:pulumi.ResourceOptions = None):
        super().__init__('KDBFullSensor', name, None, opts)
        self.path = os.path.dirname(os.path.abspath(__file__))
        self.stubs = []
        self.name = name

        self.tp_user = prand.RandomString("tp_user-"+self.name,length=10,special=False);
        self.tp_pass = prand.RandomPassword("tp_pass-"+self.name,length=16,special=True);
        self.tp_port = 5000;
        self.pull_policy = "IfNotPresent"

        # The sensor can be of any image format
        # which would allow for the tickerplant and
        # hdb to act as a sidecar therin
        self.sensor_stub = ImageBuilder(
               name="thorad/sensor",
               base_image="kdb32",
               prefix="sensor",
               path=self.path,
               skip_push=False,
               files=[
                "sensor.q"
               ],
               command="q sensor.q -t 100"
        )
        self.stubs.append(self.sensor_stub)

        # The tickerplant listens to updates recieved from the
        # the sensor and dispatches them to the hdb worker and
        # the respective aggregators/rdbs
        self.tp_stub = ImageBuilder(
               name="thorad/tickerplant",
               base_image="kdb32",
               prefix="tp",
               path=self.path,
               skip_push=False,
               files=[
                "sensor.q"
               ],
               command="q sensor.q -t 100"
        )
        self.stubs.append(self.tp_stub)

        # The hdb receives events from the tickerplant, batches them
        # and writes them to persistent store, if there are older stores
        # the hdb will move the data to the historic store
        self.hdb_stub = ImageBuilder(
               name="thorad/hdb",
               base_image="kdb32",
               prefix="hdb",
               path=self.path,
               skip_push=False,
               files=[
                "hdb.q"
               ],
               command="q hdb.q -t 100"
        )
        self.stubs.append(self.hdb_stub)

        # The statefule persistent volume claim 
        self.pvc = k8s.core.v1.PersistentVolumeClaim(
            self.name,
            metadata=k8s.meta.v1.ObjectMetaArgs(
                name=self.name,
            ),
            spec=k8s.core.v1.PersistentVolumeClaimSpecArgs(
                access_modes=["ReadWriteOnce"],
                resources=k8s.core.v1.ResourceRequirementsArgs(
                    requests={
                        "storage": "8Gi",
                    },
                ),
            ),
            opts=pulumi.ResourceOptions(parent=self),
        )

        # Using a stateful set per sensor allows for logical replcation
        labels = { 'app': self.name+'-sensor-{0}-{1}'.format(get_project(), get_stack()) }
        self.tp_deployment = k8s.apps.v1.StatefulSet("sensor-deployment-"+self.name,
            spec=k8s.apps.v1.StatefulSetSpecArgs(
                selector=k8s.meta.v1.LabelSelectorArgs(match_labels=labels),
                service_name=self.name+"-sensor-service",
                replicas=1,
                # Update strategy
                template=k8s.core.v1.PodTemplateSpecArgs(
                    metadata=k8s.meta.v1.ObjectMetaArgs(labels=labels),
                    spec=k8s.core.v1.PodSpecArgs(
                          volumes=[
                            k8s.core.v1.VolumeArgs(
                                name="hdb-data",
                                persistent_volume_claim=k8s.core.v1.PersistentVolumeClaimVolumeSourceArgs(
                                    claim_name=self.name,
                                ),
                            ),
                          ],
                          containers=[
                          k8s.core.v1.ContainerArgs(
                                name=self.name+"-sensor",
                                image=self.sensor_stub.image.image_name,
                                image_pull_policy=self.pull_policy,
                                # env=[
                                #     k8s.core.v1.EnvVarArgs(name="SENSOR_NAME", value=self.name),
                                #     k8s.core.v1.EnvVarArgs(name="TP_PORT", value=self.tp_port),
                                #     k8s.core.v1.EnvVarArgs(name="TP_HOST", value="localhost"),
                                #     k8s.core.v1.EnvVarArgs(name="TP_USER", value=self.tp_user),
                                #     k8s.core.v1.EnvVarArgs(name="TP_PASS", value=self.tp_pass)
                                # ],
                                # ports=[
                                #       k8s.core.v1.ContainerPortArgs(container_port=8080)
                                # ],
                                # resources=k8s.core.v1.ResourceRequirementsArgs(
                                #     requests={
                                #         "cpu": "100m",
                                #         "memory": "100Mi",
                                #     },
                                # ),
                          ),
                          k8s.core.v1.ContainerArgs(
                                name=self.name+"-tickerplant",
                                image=self.tp_stub.image.image_name,
                                image_pull_policy=self.pull_policy,
                                # env=[
                                #     k8s.core.v1.EnvVarArgs(name="TP_PORT", value=self.tp_port),
                                #     k8s.core.v1.EnvVarArgs(name="TP_HOST", value="localhost"),
                                #     k8s.core.v1.EnvVarArgs(name="TP_USER", value=self.tp_user),
                                #     k8s.core.v1.EnvVarArgs(name="TP_PASS", value=self.tp_pass)
                                # ],
                                # ports=[
                                #       k8s.core.v1.ContainerPortArgs(container_port=8081),
                                #       k8s.core.v1.ContainerPortArgs(container_port=self.tp_port)
                                # ],
                                # resources=k8s.core.v1.ResourceRequirementsArgs(
                                #     requests={
                                #         "cpu": "100m",
                                #         "memory": "100Mi",
                                #     },
                                # ),
                          ),
                          k8s.core.v1.ContainerArgs(
                                name=self.name+"-hdb",
                                image=self.hdb_stub.image.image_name,
                                image_pull_policy=self.pull_policy,
                                # env=[
                                #     k8s.core.v1.EnvVarArgs(name="TP_PORT", value=self.tp_port),
                                #     k8s.core.v1.EnvVarArgs(name="TP_HOST", value="localhost"),
                                #     k8s.core.v1.EnvVarArgs(name="TP_USER", value=self.tp_user),
                                #     k8s.core.v1.EnvVarArgs(name="TP_PASS", value=self.tp_pass)
                                # ],
                                # ports=[
                                #       k8s.core.v1.ContainerPortArgs(container_port=8082)
                                # ],
                                # resources=k8s.core.v1.ResourceRequirementsArgs(
                                #     requests={
                                #         "cpu": "100m",
                                #         "memory": "100Mi",
                                #     },
                                # ),
                                volume_mounts=[
                                    k8s.core.v1.VolumeMountArgs(
                                        name="hdb-data",
                                        mount_path="/data",
                                    ),
                                ],
                          )
                      ]),
                ),
                # volume_claim_templates = [
                #         k
                # ]
            ))

        # // allow external aggregators to subscribe to the tickerplant
        #self.tp_service = k8s.core.v1.Service("tickerplant-service-"+self.name,
        #        spec=k8s.core.v1.ServiceSpecArgs(
        #            type='LoadBalancer',
        #            selector=labels,
        #            ports=[k8s.core.v1.ServicePortArgs(port=self.tp_port)],
        #))

        #self.rdb_labels = {
        #    "app": "rdb",
        #    "tier": "aggregation",
        #    "role": "master"
        #}

        #self.rdb_stub = ImageBuilder(
        #       name="rdb",
        #       base_image="kdb32",
        #       prefix="rdb",
        #       path=self.path,
        #       files=[
        #        "rdb.q"
        #       ],
        #       command="q rdb.q"
        #)
        #self.stubs.append(self.rdb_stub)

        ## 
        #self.rdb_deployment = k8s.apps.v1.Deployment('rdb-deployment-'+self.name,
        #    spec=k8s.apps.v1.DeploymentSpecArgs(
        #        selector=k8s.meta.v1.LabelSelectorArgs(match_labels=self.rdb_labels),
        #        replicas=1,
        #        template=k8s.core.v1.PodTemplateSpecArgs(
        #            metadata=k8s.meta.v1.ObjectMetaArgs(labels=self.rdb_labels),
        #            spec=k8s.core.v1.PodSpecArgs(containers=[
        #                    k8s.core.v1.ContainerArgs(
        #                            name=self.name+"-hdb",
        #                            image=self.rdb_stub.image.image_name,
        #                            env=[
        #                                k8s.core.v1.EnvVarArgs(name="TP_PORT", value=self.tp_port),
        #                                k8s.core.v1.EnvVarArgs(name="TP_HOST", value=""),
        #                                k8s.core.v1.EnvVarArgs(name="TP_USER", value=self.tp_user),
        #                                k8s.core.v1.EnvVarArgs(name="TP_PASS", value=self.tp_pass)
        #                            ],
        #                            ports=[k8s.core.v1.ContainerPortArgs(
        #                                container_port=8080,
        #                            )],
        #                            resources=k8s.core.v1.ResourceRequirementsArgs(
        #                                requests={
        #                                    "cpu": "100m",
        #                                    "memory": "1Gi",
        #                                },
        #                            ),
        #                   ),
        #              ]),
        #        ),
        #    ),
        #)


    def clean(self):
        for s in self.stubs:
            print(s.dockerfile_path)


