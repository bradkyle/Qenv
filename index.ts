import * as pulumi from "@pulumi/pulumi";
import * as dev from "./infra/stacks/development";
import * as prd from "./infra/stacks/production";
import * as stg from "./infra/stacks/staging";
import * as tst from "./infra/stacks/testing";

dev.setup()