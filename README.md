# Link-Shortener & -Tracker
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