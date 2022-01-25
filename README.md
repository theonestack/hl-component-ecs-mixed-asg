# ecs-mixed-asg CfHighlander Project


## Cfhighlander Setup

install cfhighlander [gem](https://github.com/theonestack/cfhighlander)

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```
## Compiling the project

compiling with the validate tag to validate the templates

```bash
cfcompile ec2-mixed-asg --validate
```

publish the templates to s3

```bash
cfpublish ec2-mixed-asg --version latest
```
