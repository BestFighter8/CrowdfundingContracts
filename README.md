# CrowdfundingDapp

These are 3 contracts that are possible to use. 

arrays.sol
Arrays is the simplest und the worst optimized, but works the best with our React App. Doesn't have the refund function tho.

mappings.sol
mappings uses no arrays, so it's more optimized. I can simply use nested mapping (one maping inside another) to store all the donators only for specific campaign. It works fine, but can't be iterated cause of that mapping. Without iteration we can't always access campaigns list from our storage and require a backend to store those campaigns.

viewstruct.sol
viestruct is the best for out case imo. Works fine, uses everything from mappings.sol, but has the second sctruct just to show existing campaigns continuously.

All documents include comments in them, so open each one to get more details.
