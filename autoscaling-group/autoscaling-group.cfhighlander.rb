CfhighlanderTemplate do
    DependsOn 'lib-iam@0.1.0'
    DependsOn 'lib-ec2@feature/create-sg.snapshot'
    
    Parameters do
      ComponentParam 'EnvironmentName', 'dev', isGlobal: true
      ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
      ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
      ComponentParam 'Subnets', type: 'CommaDelimitedList'
      ComponentParam 'SecurityGroupIds', type: 'String'
      ComponentParam 'LaunchTemplateId', type: 'String'
      ComponentParam 'DesiredCapacity', '-1', type: 'String' # allows ecs capacity provider to determine the desired count
      ComponentParam 'MinSize', '1', type: 'String'
      ComponentParam 'MaxSize', '2', type: 'String'
      ComponentParam 'OnDemandInstanceType', '', type: 'String'
      ComponentParam 'OnDemandAllocationStrategy', 'lowest-price', allowedValues: ['lowest-price','prioritized']
      ComponentParam 'OnDemandBaseCapacity', '0', type: 'String'
      ComponentParam 'OnDemandPercentageAboveBaseCapacity', '100', type: 'String'
      ComponentParam 'SpotAllocationStrategy', 'lowest-price', allowedValues: ['lowest-price','capacity-optimized', 'capacity-optimized-prioritized'] 
      ComponentParam 'SpotInstancePools', '', type: 'String'
    end
  
  end
  