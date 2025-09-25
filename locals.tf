locals {
  env = terraform.workspace
  public_sg_security_rules = { for id, rule in csvdecode(file("${path.module}/sg_rules.csv")) : 
    id => {
      sg_name    = rule.sg_name
      rule_type  = rule.rule_type
      protocol   = rule.protocol
      from_port   = tonumber(split("-", rule.port_range)[0])
      to_port     = length(split("-", rule.port_range)) > 1 ? tonumber(split("-", rule.port_range)[1]) : tonumber(split("-", rule.port_range)[0])
      dst_cidr   = rule.dst_cidr
      dst_sg     = rule.dst_sg
    } if rule.sg_name == "main-sg-public"
  }

  private_sg_security_rules = { for id, rule in csvdecode(file("${path.module}/sg_rules.csv")) : 
    id => {
      sg_name    = rule.sg_name
      rule_type  = rule.rule_type
      protocol   = rule.protocol
      from_port   = tonumber(split("-", rule.port_range)[0])
      to_port     = length(split("-", rule.port_range)) > 1 ? tonumber(split("-", rule.port_range)[1]) : tonumber(split("-", rule.port_range)[0])
      dst_cidr   = rule.dst_cidr
      dst_sg     = rule.dst_sg
    } if rule.sg_name == "main-sg-private"
  }
}