CloudFormation do
  
  Condition('KeyNameSet', FnNot(FnEquals(Ref('KeyName'), '')))

  tags = external_parameters.fetch(:tags, {})
  template_tags = []
  template_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-#{component_name}") })
  template_tags.push({ Key: 'Environment', Value: Ref(:EnvironmentName) })
  template_tags.push({ Key: 'EnvironmentType', Value: Ref(:EnvironmentType) })
  template_tags.push(*tags.map {|k,v| {Key: k, Value: FnSub(v)}}).uniq { |h| h[:Key] } if defined? tags




  policies = []
  iam_policies.each do |name,policy|
    policies << iam_policy_allow(name,policy['action'],policy['resource'] || '*')
  end if defined? iam_policies

  Role('Role') do
    AssumeRolePolicyDocument service_role_assume_policy('ec2')
    Path '/'
    Policies(policies)
  end

  InstanceProfile('InstanceProfile') do
    Path '/'
    Roles [Ref('Role')]
  end
  
  instance_tags = external_parameters.fetch(:instance_tags, {})
  launch_template_name = external_parameters.fetch(:instance_tags, external_parameters[:component_name])
  fleet_tags = template_tags.clone
  fleet_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-#{launch_template_name}-xx") })
  fleet_tags.push(*instance_tags.map {|k,v| {Key: k, Value: FnSub(v)}})
  fleet_tags = fleet_tags.reverse.uniq { |h| h[:Key] }
  
  # Setup userdata string
  instance_userdata = "#!/bin/bash\nset -o xtrace\n"
  instance_userdata << userdata if defined? userdata
  instance_userdata << efs_mount if enable_efs
  instance_userdata << cfnsignal if defined? cfnsignal

  template_data = {
      SecurityGroupIds: FnSplit(',', Ref(:SecurityGroupIds)),
      TagSpecifications: [
        { ResourceType: 'instance', Tags: fleet_tags },
        { ResourceType: 'volume', Tags: fleet_tags },
        { ResourceType: 'launch-template', Tags: template_tags }
      ],
      UserData: FnBase64(FnSub(instance_userdata)),
      IamInstanceProfile: { Name: Ref(:InstanceProfile) },
      KeyName: FnIf('KeyNameSet', Ref('KeyName'), Ref('AWS::NoValue')),
      ImageId: Ref('Ami'),
      Monitoring: { Enabled: detailed_monitoring }
  }

  if defined? volumes
    template_data[:BlockDeviceMappings] = volumes
  end

  EC2_LaunchTemplate(:LaunchTemplate) {
    LaunchTemplateData(template_data)
    LaunchTemplateName FnSub("${EnvironmentName}-#{launch_template_name}")
  }

  Output(:Id) {
    Value(Ref('LaunchTemplate'))
    Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-Id")
  }

  Output(:Name) {
    Value(FnSub("${EnvironmentName}-#{launch_template_name}"))
    Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-Name")
  }

  Output(:LatestVersionNumber) {
    Value(FnGetAtt('LaunchTemplate','LatestVersionNumber'))
    Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-LatestVersionNumber")
  }

  Output(:DefaultVersionNumber) {
    Value(FnGetAtt('LaunchTemplate','LatestVersionNumber'))
    Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-DefaultVersionNumber")
  }
  
end
