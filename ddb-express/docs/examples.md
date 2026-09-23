# Examples

## Basic Table with LSI

```hcl
module "table" {
  source = "./ddb-express"

  table_name          = "orders"
  hash_key_attribute  = "OrderID"
  range_key_attribute = "OrderDate"

  attributes = [
    { attr_name = "OrderID", attr_type = "S" },
    { attr_name = "OrderDate", attr_type = "S" },
    { attr_name = "Status", attr_type = "S" }
  ]

  lsi_list = [
    {
      name            = "StatusIndex"
      range_key       = "Status"
      projection_type = "ALL"
    }
  ]
}
```
