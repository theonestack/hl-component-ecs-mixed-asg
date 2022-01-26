CloudFormation do

  # create_security_group('SecurityGroup', Ref('VPCId'), FnSub("${EnvironmentName}-ECS Mixed ASG"),  external_parameters.fetch(:ingress_rules, []))

  EC2_SecurityGroup(:SecurityGroup) do
    VpcId Ref('VPCId')
    GroupDescription "#{external_parameters[:component_name]} fargate service"
    Metadata({
      cfn_nag: {
        rules_to_suppress: [
          { id: 'F1000', reason: 'ignore egress for now' }
        ]
      }
    })
  end

end