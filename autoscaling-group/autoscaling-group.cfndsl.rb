CloudFormation do

  asg_name = external_parameters.fetch(:asg_name, "${EnvironmentName}-#{external_parameters[:component_name]}")
  capacity_rebalance = external_parameters.fetch(:capacity_rebalance, nil)
  max_instance_lifetime = external_parameters.fetch(:max_instance_lifetime, nil)

  Condition(:HasDesiredCapacity, FnNot(FnEquals(Ref(:DesiredCapacity), '-1')))

  AutoScaling_AutoScalingGroup(:asg) do
    AutoScalingGroupName FnSub(asg_name)
    CapacityRebalance capacity_rebalance unless capacity_rebalance.nil?
    HealthCheckType 'ec2'
    DesiredCapacity FnIf('HasDesiredCapacity', Ref(:DesiredCapacity), Ref('AWS::NoValue'))
    MinSize Ref(:MinSize)
    MaxSize Ref(:MaxSize)
    MaxInstanceLifetime max_instance_lifetime unless max_instance_lifetime.nil?
    MixedInstancesPolicy ({
      InstancesDistribution: {
        OnDemandAllocationStrategy: 'prioritized',
        OnDemandBaseCapacity: 0,
        OnDemandPercentageAboveBaseCapacity: 0,
        SpotAllocationStrategy: 'capacity-optimized-prioritized',
        SpotInstancePools: 5,
        SpotMaxPrice: ''
      },
      LaunchTemplate: {
        LaunchTemplateSpecification: {
          LaunchTemplateId: Ref(:LaunchTemplateId),
          Version: Ref(:LaunchTemplateVersion)
        },
        Overrides: []
      }
    })
    VPCZoneIdentifier Ref(:Subnets)
  end

end


# Type: AWS::AutoScaling::AutoScalingGroup
# Properties: 
#   AutoScalingGroupName: String
#   AvailabilityZones: 
#     - String
#   CapacityRebalance: Boolean
#   Context: String
#   Cooldown: String
#   DesiredCapacity: String
#   DesiredCapacityType: String
#   HealthCheckGracePeriod: Integer
#   HealthCheckType: String
#   InstanceId: String
#   LaunchConfigurationName: String
#   LaunchTemplate: 
#     LaunchTemplateSpecification
#   LifecycleHookSpecificationList: 
#     - LifecycleHookSpecification
#   LoadBalancerNames: 
#     - String
#   MaxInstanceLifetime: Integer
#   MaxSize: String
#   MetricsCollection: 
#     - MetricsCollection
#   MinSize: String
#   MixedInstancesPolicy: 
#     MixedInstancesPolicy
#   NewInstancesProtectedFromScaleIn: Boolean
#   NotificationConfigurations: 
#     - NotificationConfiguration
#   PlacementGroup: String
#   ServiceLinkedRoleARN: String
#   Tags: 
#     - TagProperty
#   TargetGroupARNs: 
#     - String
#   TerminationPolicies: 
#     - String
#   VPCZoneIdentifier: 
#     - String