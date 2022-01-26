CloudFormation do

  Condition(:HasDesiredCapacity, FnNot(FnEquals(Ref(:DesiredCapacity), '-1')))

  asg_name = external_parameters.fetch(:asg_name, "${EnvironmentName}-#{external_parameters[:component_name]}")
  capacity_rebalance = external_parameters.fetch(:capacity_rebalance, nil)
  max_instance_lifetime = external_parameters.fetch(:max_instance_lifetime, nil)
  instance_types_overrides = external_parameters.fetch(:instance_types_overrides, [Ref(:OnDemandInstanceType)])

  launch_template_overrides = []
  instance_types_overrides.each do |instance_type|
    launch_template_overrides << {
      InstanceType: instance_type,
      LaunchTemplateSpecification: {
        LaunchTemplateId: Ref(:LaunchTemplateId),
        Version: Ref(:LaunchTemplateVersion)
      }
    }
  end

  ecs_mixed_asg_tags = []
  ecs_mixed_asg_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{external_parameters[:component_name]}") }
  ecs_mixed_asg_tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  ecs_mixed_asg_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

  create_security_group('SecurityGroup', Ref('VPCId'), FnSub("${EnvironmentName}-ECS Mixed ASG"),  external_parameters.fetch(:ingress_rules, []))
  
  AutoScaling_AutoScalingGroup(:AutoScalingGroup) do
    UpdatePolicy(:AutoScalingReplacingUpdate, {
      WillReplace: true
    })
    UpdatePolicy(:AutoScalingScheduledAction, {
      IgnoreUnmodifiedGroupSizeProperties: true
    })
    AutoScalingGroupName FnSub(asg_name)
    CapacityRebalance capacity_rebalance unless capacity_rebalance.nil?
    HealthCheckType 'ec2'
    DesiredCapacity FnIf('HasDesiredCapacity', Ref(:DesiredCapacity), Ref('AWS::NoValue'))
    MinSize Ref(:MinSize)
    MaxSize Ref(:MaxSize)
    MaxInstanceLifetime max_instance_lifetime unless max_instance_lifetime.nil?
    MixedInstancesPolicy ({
      InstancesDistribution: {
        OnDemandAllocationStrategy: Ref(:OnDemandAllocationStrategy),
        OnDemandBaseCapacity: Ref(:OnDemandBaseCapacity),
        OnDemandPercentageAboveBaseCapacity: Ref(:OnDemandPercentageAboveBaseCapacity),
        SpotAllocationStrategy: Ref(:SpotAllocationStrategy),
        SpotInstancePools: Ref(:SpotInstancePools),
        SpotMaxPrice: ''
      },
      LaunchTemplate: {
        LaunchTemplateSpecification: {
          LaunchTemplateId: Ref(:LaunchTemplateId),
          Version: Ref(:LaunchTemplateVersion)
        },
        Overrides: launch_template_overrides
      }
    })
    VPCZoneIdentifier Ref(:Subnets)
    Tags ecs_mixed_asg_tags.each {|tag| tag[:PropagateAtLaunch]=false}
  end

  Output(:AutoScalingGroup) {
    Value(Ref(:AutoScalingGroup))
  }


end