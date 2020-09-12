tests for depth 
tests for 

move logic for inverse/linear/quanto into their own files
shared logic between the 2


// 
// TODO implement macro actions!
// - Hidden Orders
// - Iceberg Orders
// - sell 1, sell 2, sell 3, buy 3, buy 1, buy 2, exit position, etc. 
// action tree

// BENCHMARK
2.0 million and 2.5 million inserts per second

Run pipeline and engine in different process
// add the ability to place iceberg orders


// FINISH loader, write tests, run training

// TODO change ingress to egress and visa versa

// TODO route all traffic through private computer.

// d if there’s ever a severe failure, we have a separate program which does nothing but cancel-all-orders, positions

// The brokers use (buggy) software (too).

I've had to change my code to protect their system from malfunctioning. I've repaired an API SDK for a broker. I've even seen a broker that had their simple math wrong.

It's better to have your own error checking.

https://www.aquaq.co.uk/datablog/kdb-anymap-unstructured/