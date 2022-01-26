CfhighlanderTemplate do

    Parameters do
      ComponentParam 'EnvironmentName', 'dev', isGlobal: true
      ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
      ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
      ComponentParam 'SecurityGroupIds', type: 'String'
      ComponentParam 'LaunchTemplateArn', type: 'String'
      ComponentParam 'DesiredCapacity', '-1', type: 'String' # allows ecs capacity provider to determine the desired count
      ComponentParam 'MinSize', '1', type: 'String'
      ComponentParam 'MaxSize', '2', type: 'String'
      ComponentParam 'OnDemandInstanceType', '', type: 'String'
    end
  
  end
  