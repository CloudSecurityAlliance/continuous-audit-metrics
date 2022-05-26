# The Continuous Audit Metrics Catalog

The Cloud Security Alliance (CSA) has launched an initiative to create a [continuous assessment framework for cloud security](https://cloudsecurityalliance.org/research/working-groups/continuous-audit-metrics/). As part of that work, CSA is building a **Continuous Audit Metrics Catalog** for the cloud to help organizations assess the security of information systems on a near-continuous basis. 

A [version 1.0 of the continuous audit metrics catalog](https://cloudsecurityalliance.org/artifacts/the-continuous-audit-metrics-catalog/) was released 10/19/2021. That document provides background on security metrics and continuous auditing, the use of metrics to increase the maturity of an organization's governance and risk management, a basic description of the metric format, and the initial catalog of 34 continuous audit metrics addressing controls from the [CSA CCMv4](https://cloudsecurityalliance.org/research/cloud-controls-matrix/).

This repository contains the [YAML](https://en.wikipedia.org/wiki/YAML) definition of the CSA's **Continuous Audit Metrics Catalog** in `data/primary-dataset.yml`, which will serve as a basis for the next release of this catalog. This work is hosted on GitHub to encourage everyone in the security community to contribute by directly proposing _pull requests_ or by creating _github issues_.

An HTML preview of the current state of this catalog is available [here](http://htmlpreview.github.io/?https://github.com/cloudsecurityalliance/continuous-audit-metrics/blob/main/metrics-catalog.html). 

Cloud Security Aliance summit in Oct 2021 included a presentation on the Continuous Audit Metrics catalog work. The full presentation can be watched as part of the summit material on [brightTALK](https://www.brighttalk.com/webcast/10415/511360) and the [PDF](https://github.com/cloudsecurityalliance/continuous-audit-metrics/blob/main/docs/v2ContinuousAuditBrightTALK.pdf) is available for download. 

In addition to the **Continuous Audit Metrics Catalog**, this repository also hosts Auditing guidelines for continuous audit metrics.

To engage with this work, please also consider joining the [CSA Continuous Audit Metrics working group](https://cloudsecurityalliance.org/research/working-groups/continuous-audit-metrics/) for real-time discussions.

## How to contribute 

### Adding new metrics to the Catalog

The structure of a metric is detailed [here](https://github.com/cloudsecurityalliance/continuous-audit-metrics/wiki/Content-of-a-metric).

There are two ways to contribute new metrics to the Catalog. 

#### 1. With a pull-request

First, you can modify the YAML file `data/primary-dataset.yml` and add the metrics you want. Then create a PR (pull-request) on this GitHub repository. 

The community will discuss this pull request and potentially add it to the catalog.

#### 2. With a GitHub issue

Second, if you are not comfortable with YAML or pull-request, you can also propose a metric by simply creating an issue here on GitHub. As a minimum, your proposal should contain the following fields:

- Metric Description
- Expression
- Rules
- SLO recommendations

These fields are detailed [here](https://github.com/cloudsecurityalliance/continuous-audit-metrics/wiki/Content-of-a-metric).

### Suggesting changes or corrections to existing metrics

To suggest changes or corrections to existing metrics in the catalog, please follow the same process as for new metrics: either create a pull request or a GitHub issue.

## Licensing

The YAML file representing the CSA continuous audit metrics and any associated documentation provided in this repository are licensed under 
the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license as described in the LICENSE file.

For commercial use of this work, please contact CSA at research@cloudsecurityalliance.org

## Open source tools

Open source tools to use the metrics are being worked on in the [CAML](https://github.com/continube/CAML) repository. 

