provider "aws" {
	region = "ap-south-1"
	profile = "default"
	}

resource "aws_instance" "instance-1" {
	ami = "ami-010aff33ed5991201"
	instance_type = "t2.micro"
	availability_zone = "ap-south-1a"
	security_groups= ["launch-wizard-1"]
	tags = {	Name = "Task6"	}
	key_name = "mumbaikey"
}

resource "aws_ebs_volume" "ebs-vol" {
  	availability_zone = aws_instance.instance-1.availability_zone
  	size              = 1
  	tags = {
    	Name = "Web Server HD by TF"
  	}
}
resource "aws_volume_attachment" "ebs_attach" {
  	device_name = "/dev/sdc"
  	volume_id   = aws_ebs_volume.ebs-vol.id
  	instance_id = aws_instance.instance-1.id
  	force_detach = true
}


resource "null_resource" "null_res1" {
depends_on = [aws_volume_attachment.ebs_attach,]

	connection {
	type="ssh"
	user="ec2-user"
	private_key=file("C:/Users/sharm/Downloads/mumbaikey.pem")
	host=aws_instance.instance-1.public_ip
}

provisioner "remote-exec" {
    inline = [
	"sudo yum install httpd -y",
	"sudo yum install php -y",
	"sudo systemctl enable httpd --now",
	"sudo mkfs.ext4 /dev/xvdc",
	"sudo  mount /dev/xvdc  /var/www/html",
	"sudo yum install git -y",
	"sudo git clone https://github.com/Udit-Sharma2020/WEBAPP_js_html.git   /var/www/html/web"
    ]
  }

}
