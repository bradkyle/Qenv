import * as pulumi from "@pulumi/pulumi";
import * as dev from "./stacks/development";
import * as prd from "./stacks/production";
import * as stg from "./stacks/staging";
import * as tst from "./stacks/testing";

dev.setup()
