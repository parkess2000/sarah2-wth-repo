param registryLocation string = 'South Central US'
param registrySku string = 'Standard'
param appInsightsLocation string = 'South Central US'
param sku string = 'S1'
param webAppName string = '<prefix>devops-dev'
param hostingPlanName string = '<prefix>devops-asp'
param appInsightsName string = '<prefix>devops-ai'
param registryName string = '<prefix>devopsreg'
param imageName string = '<prefix>devopsimage'
param startupCommand string = ''

resource registry 'Microsoft.ContainerRegistry/registries@2017-10-01' = {
    name: registryName,
    location: registryLocation,
    sku: { name: registrySku },
    properties: {
        adminUserEnabled: true
    }
}

resource appInsight 'Microsoft.Insights/components@2015-05-01' = {
    name: appInsightsName,
    location: appInsightsLocation,
    properties: {}
}

resource hostingPlan 'Microsoft.Web/serverfarms@2016-09-01' = {
    name: hostingPlanName,
    location: resourceGroup().location,
    sku: {
        name: sku
    },
    properties: {}
}

resource webApp 'Microsoft.Web/sites@2016-03-01' = {
    name: webAppName,
    location: resourceGroup().location,
    properties: {
        name: webAppName,
        serverFarmId: hostingPlan.id,
        siteConfig: {
            appSettings: [
                {
                    name: 'DOCKER_REGISTRY_SERVER_URL',
                    value: 'https://' + registry.loginServer
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_USERNAME',
                    value: registry.username
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_PASSWORD',
                    value: registry.password
                },
                {
                    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE',
                    value: 'false'
                },
                {
                    name: 'APPINSIGHTS_INSTRUMENTATIONKEY',
                    value: appInsight.InstrumentationKey
                }
            ],
            appCommandLine: startupCommand,
            linuxFxVersion: 'DOCKER|' + registry.loginServer + '/' + imageName
        },
    },
    tags: {
        "[concat('hidden-related:', '/subscriptions/', subscription().subscriptionId,'/resourcegroups/', resourceGroup().name, '/providers/Microsoft.Web/serverfarms/', hostingPlanName)]": "empty"
    },
    dependsOn: [
        registry,
        appInsight,
        hostingPlan
    ]
}
