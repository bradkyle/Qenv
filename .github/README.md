
name: train-my-model
on: [push]
jobs:
  build:
    name: Build the qenv containers and run unit tests 
    runs-on: ubuntu-latest
    steps:
      - name:

  unit:
    name: Build and run unit tests/integration tests
    runs-on: ubuntu-latest
    steps:
      - name:

  e2e:
    name: Create a minikube cluster for end to end deployment 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Setup Minikube
        uses: manusa/actions-setup-minikube@v2.1.0
        with:
          minikube version: 'v1.13.1'
          kubernetes version: 'v1.19.2'
          github token: ${{ secrets.GITHUB_TOKEN }}
      - name: Deploy the testing cluster with pulumi 
        run: pulumi up 

  train:
    name: Deploy the training cluster to the configured remote
    runs-on: 
    steps:
      -name: 

  staging:
    name: Deploy the staging cluster to the configured remote
    runs-on:

  alpha:
    name: Deploy the tierone production cluster to the configured remote
    steps:
      - name: Pulumi up 

  beta:
    name: Deploy the tiertwo production cluster to the configured remote
    steps:
      - name: Pulumi up 
    
  prime:
    name: Deploy the tiertwo production cluster to the configured remote
    steps:
      - name: Pulumi up 

  