CfhighlanderTemplate do

  DependsOn 'lib-iam@0.1.0'
  DependsOn 'lib-ec2@0.1.0'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'Subnets', type: 'CommaDelimitedList'
    ComponentParam 'EcsCluster', type: 'String'
    ComponentParam 'OnDemandInstanceType', '', type: 'String'

  end

  Component template: 'launch-template', name: 'launchtemplate', render: Inline, config: @config do
    parameter name: 'VPCId', value: Ref(:VPCId)
    parameter name: 'EcsCluster', value: Ref(:EcsCluster)
    parameter name: 'InstanceType', value: Ref(:OnDemandInstanceType)
  end

  Component template: 'autoscaling-group', name: 'ecs-mixed', render: Inline, config: @config do
    parameter name: 'VPCId', value: Ref(:VPCId)
    parameter name: 'Subnets', value: Ref(:Subnets)
    parameter name: 'LaunchTemplateId', value: cfout('launchtemplate.Id')
    parameter name: 'LaunchTemplateVersion', value: cfout('launchtemplate.LatestVersionNumber')
  end

end
