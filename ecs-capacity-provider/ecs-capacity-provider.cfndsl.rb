
CloudFormation do

  default_tags = external_parameters.fetch(:default_tags, [])

  managed_scaling = external_parameters.fetch(:managed_scaling).transform_keys {|k| k.split('_').collect(&:capitalize).join }
  provider_name = external_parameters.fetch(:provider_name,nil)

  ECS_CapacityProvider(:CapacityProvider) do
    Name FnSub(provider_name) unless provider_name.nil?
    AutoScalingGroupProvider ({
      AutoScalingGroupArn: Ref(:AutoScalingGroup),
      ManagedScaling: managed_scaling
    })
    Tags default_tags
  end

  ECS_ClusterCapacityProviderAssociations(:ClusterCapacityProviderAssociations) do
    Cluster Ref(:EcsCluster)
    CapacityProviders [ Ref(:CapacityProvider) ]
    DefaultCapacityProviderStrategy [{
      Base: Ref(:BaseCapacity),
      CapacityProvider: Ref(:CapacityProvider),
      Weight: 1
    }]
  end

end