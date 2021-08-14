<div style="text-align:center"><img src="https://github.com/R4h4/shortrLink/raw/main/assets/shortrLink_logo.png" /></div>

# shotrLink - A serverless URL shortener on AWS
The problem statement is simple: We want to be able to share 
links, but:
   1. Most URLs are too long to i.e. fit into a Tweet; and
   2. It would be interesting to know how many people click 
   on said link

Considerations: The usage patterns for this tool are yet unknown, 
and we can expect a very spiky load-pattern at least in the beginning.
Solution: A serverless architecture that is cheap to maintain with little
traffic and has the ability to seamlessly scale up when needed.

This project is too small to justify a microservice architecture, but 
we will adhere to a frontend- backend-separation pattern.

## Infrastructure
<img src="https://github.com/R4h4/shortrLink/raw/main/assets/ShortrLink-infrastructure-cross-region.jpg" />
shortrLink utilizes 100% serverless components on AWS. To decrease re-direction latency, the redirection-service as well as the DynamoDb link table, are replicated across multiple regions.
