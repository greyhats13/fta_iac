# Terraform Cloud Deployment

## Table of Contents

- [Overview](#overview)
- [Architecture and Design](#architecture-and-design)
  - [Modular Structure](#modular-structure)
  - [Resource Interactions](#resource-interactions)
    - [Virtual Private Cloud (VPC)](#virtual-private-cloud-vpc)
    - [Google Kubernetes Engine (GKE)](#google-kubernetes-engine-gke)
    - [Compute Instances (Atlantis)](#compute-instances-atlantis)
    - [Cloud SQL Instance](#cloud-sql-instance)
    - [Key Management Service (KMS)](#key-management-service-kms)
    - [Helm Charts](#helm-charts)
      - [ArgoCD](#argocd)
      - [Nginx Ingress Controller](#nginx-ingress-controller)
      - [External DNS](#external-dns)
- [Deployment Process](#deployment-process)
  - [Prerequisites](#prerequisites)
  - [Terraform Deployment with Atlantis](#terraform-deployment-with-atlantis)
    - [Atlantis Workflow](#atlantis-workflow)
    - [Step-by-Step Deployment](#step-by-step-deployment)
- [Conclusion](#conclusion)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

## Overview

This repository contains Terraform configurations meticulously crafted to deploy and manage a comprehensive cloud infrastructure on **Google Cloud Platform (GCP)**. The deployment encompasses critical components such as networking, storage, security, continuous integration/continuous deployment (CI/CD) pipelines, and Kubernetes orchestration. Leveraging Terraform's Infrastructure as Code (IaC) capabilities, this setup ensures reproducibility, scalability, and efficient management of cloud resources, adhering to industry best practices and organizational standards.

## Architecture and Design

### Modular Structure

The Terraform code is organized into distinct modules, each encapsulating specific aspects of the cloud infrastructure. This modular approach promotes maintainability, reusability, and clarity, enabling teams to manage complex deployments efficiently. The primary modules include:

- **GCP Project Management**: Configures the GCP project and enables essential APIs.
- **Networking (VPC)**: Establishes a Virtual Private Cloud (VPC) with custom subnets, firewall rules, and NAT configurations.
- **Storage (GCS)**: Creates a Google Cloud Storage bucket dedicated to storing Terraform state files securely.
- **Security (KMS & Secret Manager)**: Implements Key Management Service (KMS) for encrypting secrets and manages sensitive data using Google Secret Manager.
- **CI/CD Pipelines (Atlantis & ArgoCD)**: Deploys Atlantis for Terraform automation and ArgoCD for GitOps-based continuous deployment.
- **Kubernetes Infrastructure (GKE)**: Sets up a Google Kubernetes Engine (GKE) cluster with necessary configurations and add-ons.
- **DNS Management**: Configures Cloud DNS for managing domain names and DNS records.

### Resource Interactions

The seamless interaction between resources, modules, and components is pivotal for the efficient deployment and operation of the cloud infrastructure. Below is a detailed explanation of how each component interacts within the deployment:

#### Virtual Private Cloud (VPC)

The **VPC** serves as the foundational network for all deployed resources. It is configured with custom subnets to segregate different types of workloads and includes firewall rules to control inbound and outbound traffic. Key interactions include:

- **GKE Integration**: The VPC provides the network environment for the GKE cluster, ensuring that Kubernetes nodes and services have the necessary network configurations.
- **Compute Instances (Atlantis)**: Atlantis instances are deployed within the VPC, leveraging private subnets for secure communication with other resources.
- **Cloud SQL Access**: The VPC facilitates secure connectivity between GKE pods and the Cloud SQL instance through private IPs, ensuring data remains within the internal network.
- **Firewall Rules**: Defined firewall rules within the VPC manage traffic flow to and from compute instances, Kubernetes nodes, and other services, enhancing security.

#### Google Kubernetes Engine (GKE)

The **GKE** cluster orchestrates containerized applications, providing scalability and resilience. Its interactions include:

- **Networking**: GKE utilizes the VPC's subnets for node communication and service exposure. Secondary IP ranges are allocated for pods and services, ensuring efficient IP management.
- **Helm Charts Deployment**: GKE leverages Helm charts to deploy Kubernetes add-ons like ArgoCD, Nginx Ingress Controller, and External DNS, facilitating streamlined application deployments.
- **Cloud SQL Connectivity**: GKE pods connect to the Cloud SQL instance using private IPs managed within the VPC, ensuring secure database interactions.
- **Service Accounts and IAM**: GKE integrates with IAM roles to manage permissions for accessing other GCP services, such as Secret Manager and KMS.

#### Compute Instances (Atlantis)

**Atlantis** is deployed as a Compute Engine instance within the VPC to manage Terraform workflows. Its interactions include:

- **GitHub Integration**: Atlantis listens to GitHub webhooks to trigger Terraform plans and applies based on pull requests, ensuring infrastructure changes are reviewed and approved.
- **Secrets Management**: Atlantis accesses encrypted secrets from Google Secret Manager, decrypting them using KMS for secure operations.
- **CI/CD Pipeline**: Atlantis interacts with other CI/CD tools like ArgoCD to ensure seamless integration and deployment of infrastructure changes.

#### Cloud SQL Instance

The **Cloud SQL** instance provides a managed PostgreSQL database service, interacting with:

- **GKE**: Kubernetes applications running on GKE connect to Cloud SQL for persistent storage, utilizing private IPs for secure communication.
- **VPC Networking**: The Cloud SQL instance is configured within the VPC, ensuring it adheres to network policies and firewall rules defined for secure access.
- **Backup and Maintenance**: Cloud SQL integrates with GCP's backup and maintenance services, ensuring data durability and availability.

#### Key Management Service (KMS)

**KMS** plays a crucial role in securing sensitive data by:

- **Encrypting Secrets**: KMS encrypts secrets stored in Google Secret Manager, ensuring that sensitive information like GitHub tokens and OAuth secrets remain secure.
- **Integration with Terraform**: Terraform modules utilize KMS to encrypt and decrypt secrets during the deployment process, maintaining security throughout the infrastructure lifecycle.
- **Access Control**: IAM roles govern access to KMS keys, ensuring that only authorized entities can perform encryption and decryption operations.

#### Helm Charts

Helm charts are utilized to deploy and manage Kubernetes add-ons, each interacting with the infrastructure as follows:

##### ArgoCD

**ArgoCD** facilitates GitOps-based continuous deployment by:

- **GitHub Integration**: ArgoCD monitors GitHub repositories for changes, automatically deploying applications based on the defined Git workflows.
- **Kubernetes Integration**: ArgoCD interacts with the GKE cluster to manage application deployments, ensuring that the desired state is maintained.
- **Secret Management**: ArgoCD accesses secrets from Google Secret Manager, decrypting them using KMS for secure deployment operations.

##### Nginx Ingress Controller

The **Nginx Ingress Controller** manages external access to Kubernetes services by:

- **DNS Integration**: It works in conjunction with External DNS to automatically configure DNS records based on service annotations, ensuring that services are discoverable.
- **Load Balancing**: Nginx handles incoming HTTP and HTTPS traffic, distributing it across Kubernetes pods to ensure high availability and scalability.
- **SSL Termination**: It integrates with Cert Manager to handle SSL certificates, enabling secure communications for exposed services.

##### External DNS

**External DNS** automates DNS record management by:

- **Cloud DNS Integration**: External DNS interacts with GCP's Cloud DNS to create and manage DNS records based on Kubernetes service annotations.
- **Dynamic Updates**: It listens to Kubernetes events and updates DNS records in real-time, ensuring that DNS entries reflect the current state of deployed services.
- **Policy Enforcement**: External DNS adheres to defined policies for DNS management, maintaining consistency and reliability in DNS configurations.

## Deployment Process

Deploying the Terraform code involves a structured series of steps to ensure a smooth and error-free setup of the cloud infrastructure. The process is streamlined using **Atlantis**, a Terraform automation tool that integrates with GitHub to manage Terraform workflows via pull requests.

### Prerequisites

Before initiating the deployment, ensure the following prerequisites are met:

1. **Terraform Installed**: Version 1.0 or higher.
2. **Google Cloud SDK**: Authenticated and configured with appropriate permissions.
3. **GitHub Access**: OAuth client ID and necessary permissions for repository management.
4. **Atlantis Setup**: Atlantis server configured and connected to your GitHub repository.
5. **Kubernetes Configuration**: Access to a Kubernetes cluster if deploying add-ons separately.
6. **Ansible**: Required if any Ansible provisioning is involved.

### Terraform Deployment with Atlantis

Atlantis automates Terraform workflows by triggering plans and applies based on GitHub pull requests. This integration ensures that infrastructure changes are reviewed and approved before being applied, enhancing collaboration and security.

#### Atlantis Workflow

1. **Pull Request (PR) Creation**: Developers create feature branches and open pull requests (PRs) to propose infrastructure changes.
2. **Atlantis Plan**: Upon PR creation or updates, Atlantis automatically runs `terraform plan` to generate an execution plan, which is posted as a comment on the PR for review.
3. **Review and Approval**: Team members review the plan, ensuring the proposed changes are appropriate and secure.
4. **Atlantis Apply**: Once the PR is approved and mergeable, Atlantis executes `terraform apply` to implement the changes in the cloud environment.

#### Step-by-Step Deployment

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/greyhats13/fta_iac.git
   cd fta_iac/deployment/cloud
   ```

2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/<your-feature-name>
   ```

3. **Modify Terraform Code**:
   Make necessary changes to the Terraform configurations as per your requirements.

4. **Commit and Push Changes**:
   ```bash
   git add .
   git commit -m "Describe your changes"
   git push origin feature/<your-feature-name>
   ```

5. **Open a Pull Request (PR)**:
   Navigate to the GitHub repository and open a PR from your feature branch to the `main` branch.

6. **Atlantis Plan Execution**:
   Atlantis detects the PR and automatically runs `terraform plan`. The generated plan is posted as a comment on the PR, detailing the proposed infrastructure changes.

7. **Review the Plan**:
   Team members review the `terraform plan` output to ensure the changes are as expected and do not introduce any issues.

8. **Merge the PR**:
   Once the plan is reviewed and approved, merge the PR into the `main` branch.

9. **Atlantis Apply Execution**:
   After merging, Atlantis automatically triggers `terraform apply` to execute the approved changes, provisioning or updating resources in GCP.

10. **Verify Deployment**:
    Upon successful application, verify the deployed resources through the GCP Console or relevant interfaces. Critical outputs such as bucket names, VPC IDs, and repository URLs will be available for reference.

11. **Post-Deployment Configuration**:
    - **CI/CD Integration**: Ensure that Atlantis and ArgoCD are correctly integrated with GitHub repositories. Verify webhook configurations for automated deployments.
    - **Kubernetes Add-ons**: Confirm that add-ons like External DNS, Nginx Ingress Controller, Cert Manager, and ArgoCD are operational within the GKE cluster.
    - **DNS Configuration**: Validate DNS records and ensure that domain names resolve correctly to the deployed services.

12. **Security Verification**:
    - **Access Controls**: Review IAM roles and permissions to ensure least privilege access.
    - **Firewall Rules**: Confirm that firewall rules are correctly configured to allow necessary traffic while blocking unauthorized access.
    - **Secrets Management**: Ensure that all secrets are securely stored and managed via Secret Manager and are inaccessible to unauthorized entities.

13. **Cleanup (Optional)**:
    If necessary, destroy the infrastructure to avoid incurring costs.
    ```bash
    terraform destroy
    ```
    Confirm the destroy action when prompted.

### Continuous Deployment

With the CI/CD pipelines in place, any changes pushed to the GitHub repositories trigger automated workflows via Atlantis and ArgoCD. This setup ensures that both infrastructure and application deployments remain consistent, up-to-date, and aligned with the desired state defined in the codebase. Continuous monitoring and automated feedback loops facilitate rapid iteration and deployment, fostering an efficient and reliable development lifecycle.

## Conclusion

This Terraform deployment offers a robust and scalable foundation for managing cloud infrastructure on GCP. By adhering to best practices in modular design, security, and automation, it facilitates efficient operations and continuous improvement of the deployed environment. The integration with Atlantis and ArgoCD enhances the CI/CD workflows, ensuring that infrastructure changes are systematically reviewed, approved, and applied, thereby maintaining consistency and reliability across deployments.

The structured approach to resource management, coupled with secure secrets handling and comprehensive networking configurations, ensures that the infrastructure is both resilient and adaptable to evolving business needs. This setup not only streamlines the deployment process but also fosters a collaborative and transparent environment for infrastructure management.

For any issues or contributions, please refer to the [Contributing Guidelines](CONTRIBUTING.md) or open an issue in the repository.

## License

This project is licensed under the [Apache-2.0 License](LICENSE).

## Acknowledgments

- [Terraform](https://www.terraform.io/)
- [Google Cloud Platform](https://cloud.google.com/)
- [GitHub](https://github.com/)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [Atlantis](https://www.runatlantis.io/)