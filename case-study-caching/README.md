# Software Architecture Sustainability Experiment

This repository is part of my master thesis. It contains the code for the experiment that I conducted 
to evaluate the sustainability of software architecture.

IDs generated using:
```
db.products
    .aggregate(
        [ { $sample: { size: 1000 } } ]
    )
    .map(function(item){ return item._id; })
```