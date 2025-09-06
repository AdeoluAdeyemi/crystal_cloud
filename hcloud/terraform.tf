terraform {
  # backend "remote" {
  #   organization = "HVC_Hetzner_Crystal"
    
  #   workspaces {
  #     name = "hcloud-cry-depl-infra"
  #   }
  # }

  cloud { 
    
    organization = "HOSTVision-Cloud-Services" 

    workspaces { 
      name = "crystal-hcloud" 
    } 
  } 

  required_providers {
    hcloud = {
        source = "hetznercloud/hcloud"
        version = "~>1.52.0"
    }
  }
}
