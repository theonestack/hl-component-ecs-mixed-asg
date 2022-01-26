CfhighlanderTemplate do

  DependsOn 'lib-iam@0.1.0'
  DependsOn 'lib-ec2@feature/create-sg.snapshot'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'Subnets', type: 'CommaDelimitedList'
    ComponentParam 'EcsCluster', type: 'String'
    ComponentParam 'KeyName', type: 'String'
    ComponentParam 'Ami', '', type: 'AWS::EC2::Image::Id'
    ComponentParam 'DesiredCapacity', '-1', type: 'String' # allows ecs capacity provider to determine the desired count
    ComponentParam 'MinSize', '1', type: 'String'
    ComponentParam 'MaxSize', '2', type: 'String'
    ComponentParam 'OnDemandInstanceType', '', type: 'String'
    ComponentParam 'OnDemandAllocationStrategy', 'lowest-price', allowedValues: ['lowest-price','prioritized']  
    ComponentParam 'OnDemandBaseCapacity', '0', type: 'String'
    ComponentParam 'OnDemandPercentageAboveBaseCapacity', '100', type: 'String'
    ComponentParam 'SpotAllocationStrategy', 'lowest-price', allowedValues: ['lowest-price','capacity-optimized', 'capacity-optimized-prioritized'] 
    ComponentParam 'SpotInstancePools', '2', type: 'String'
  end

  Component template: 'launch-template', name: 'launchtemplate', render: Inline, config: @config do
    parameter name: 'VPCId', value: Ref(:VPCId)
    parameter name: 'EcsCluster', value: Ref(:EcsCluster)
    parameter name: 'InstanceType', value: Ref(:OnDemandInstanceType)
    parameter name: 'KeyName', value: Ref(:KeyName)
    parameter name: 'Ami', value: Ref(:Ami)
    parameter name: 'SecurityGroupIds', value: cfout("ecs-mixed.SecurityGroup")
  end

  Component template: 'autoscaling-group', name: 'ecs-mixed', render: Inline, config: @config do
    parameter name: 'VPCId', value: Ref(:VPCId)
    parameter name: 'Subnets', value: Ref(:Subnets)
    parameter name: 'LaunchTemplateId', value: cfout('launchtemplate.Id')
    parameter name: 'LaunchTemplateVersion', value: cfout('launchtemplate.LatestVersionNumber')
    parameter name: 'SecurityGroupIds', value: ''
    parameter name: 'OnDemandInstanceType', value: Ref(:OnDemandInstanceType)
    parameter name: 'OnDemandAllocationStrategy', value: Ref(:OnDemandAllocationStrategy)
    parameter name: 'OnDemandBaseCapacity', value: Ref(:OnDemandBaseCapacity)
    parameter name: 'OnDemandAllocationStrategy', value: Ref(:OnDemandAllocationStrategy)
    parameter name: 'OnDemandPercentageAboveBaseCapacity', value: Ref(:OnDemandPercentageAboveBaseCapacity)
    parameter name: 'SpotAllocationStrategy', value: Ref(:SpotAllocationStrategy)
    parameter name: 'SpotInstancePools', value: Ref(:SpotInstancePools)
    parameter name: 'DesiredCapacity', value: Ref(:DesiredCapacity)
    parameter name: 'MinSize', value: Ref(:MinSize)
    parameter name: 'MaxSize', value: Ref(:MaxSize)
  end

  Component template: 'ec2-ecs-draining', name: 'ecs-draining', render: Inline, config: @config do
    parameter name: 'EcsCluster', value: Ref(:EcsCluster)
    parameter name: 'AutoScalingGroup', value: cfout('ecs-mixed.AutoScalingGroup')
  end

end
