CfhighlanderTemplate do

    Parameters do
        ComponentParam 'EnvironmentName', 'dev', isGlobal: true
        ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
      end

    Component template: 'ecs-mixed-asg@0.1.0', name: 'myasg' do
        parameter name: 'VPCId', value: FnImportValue(FnSub("${EnvironmentName}-vpc-VPCId"))
        parameter name: 'Subnets', value: FnImportValue(FnSub("${EnvironmentName}-vpc-ComputeSubnets"))
        parameter name: 'EcsCluster', value: FnImportValue(FnSub("${EnvironmentName}-ecs-EcsCluster"))
        parameter name: 'InstanceType', value: 't3.small'
        parameter name: 'KeyName', value: 'reference'
        parameter name: 'Ami', value: 'ami-01dee8f614115c3b8'
    end

    Component template: 'ecs-service@2.14.0', name: "demo" do
        parameter name: 'EcsCluster', value: FnImportValue(FnSub("${EnvironmentName}-ecs-EcsCluster"))
        parameter name: 'LoadBalancer', value: ''
        parameter name: 'Listener', value: ''
        parameter name: 'VPCId', value: FnImportValue(FnSub("${EnvironmentName}-vpc-VPCId"))
        parameter name: 'Subnets', value: FnImportValue(FnSub("${EnvironmentName}-vpc-ComputeSubnets"))
        parameter name: 'DnsDomain', value: Ref('AWS::NoValue')
        parameter name: 'DesiredCount', value: 1
        parameter name: 'MinimumHealthyPercent', value: 100
        parameter name: 'MaximumPercent', value: 200
        parameter name: 'EnableScaling', value: 'false'
        parameter name: 'StackOctet', value: '0'
      end

end