CfhighlanderTemplate do

    DependsOn 'lib-iam@0.1.0'

    Parameters do
      ComponentParam 'EnvironmentName', 'dev', isGlobal: true
      ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
      ComponentParam 'EcsCluster', '', type: 'String'
      ComponentParam 'AutoScalingGroup', type: 'String'
    end
  
  end
  