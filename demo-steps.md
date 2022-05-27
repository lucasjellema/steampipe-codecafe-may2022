Query from JSON

```
steampipe query
```

Check for all csv files in current directory

```
.inspect csv

.inspect csv.books

.inspect csv.countries

```

Query all countries in Northern Africa

```
select
  name,
  "country-code"
from
  csv.countries
where 
  "sub-region" = 'Northern Africa'  
```  


Query all books 

select *
from
  csv.books
where 
 "Genre" = 'economics'


select upper("Title"), "Author"
from
  csv.books
where 
 "Genre" = 'economics'


select "Title", "Author", "Genre", "description" as "Genre Description" , "status_points" as "Genre Status Score"
from
  csv.books b
  join
  csv.genres g
  on 
  b."Genre" = g."genre"


Return all JSON files in current working directory

```
select
  path,
  jsonb_pretty(content) as file_content
from
  json_file
```  

Query based on JSON content

```
# raw JSON content from specific files

select
  content -> 'books' as b
from
  json_file
where
  path like '%books.json' 


# Query JSON data in relationalized format

select e.item ->> 'title' as Title
     , e.item ->> 'author' as Author
from json_file b
     cross join 
     jsonb_path_query(b.content, '$.books[*]') as e(item)
where
  b.path like '%books.json' 


# filter data from JSON file - takes place after all data have been read from file

select e.item ->> 'title' as Title
     , e.item ->> 'author' as Author
from json_file b
     cross join 
     jsonb_path_query(b.content, '$.books[*]') as e(item)
where
  b.path like '%books.json' 
  and 
  e.item ->> 'title' = 'Pro Git'


# aggregate over relational result

select publisher
     , count(*) as "Number of titles"
from (
  select e.item ->> 'title' as Title
       , e.item ->> 'author' as Author
       , e.item ->> 'publisher' as Publisher
  from json_file b
       cross join 
       jsonb_path_query(b.content, '$.books[*]') as e(item)
  where
    b.path like '%books.json' 
  ) books
group by
  publisher


note: used dbfiddle for trying out queries: https://dbfiddle.uk/?rdbms=postgres_12&fiddle=fd1e17842c6b209ebdbcbd093be24dc1




Join Books from JSON and CSV sources


with books_from_json as
( select e.item ->> 'title' as title
       , e.item ->> 'author' as author
       , e.item ->> 'publisher' as publisher
       , e.item ->> 'published' as date_of_publication
       , e.item ->> 'subtitle' as subtitle
       , e.item ->> 'description' as description
       , e.item ->> 'website' as website
  from json_file b
       cross join 
       jsonb_path_query(b.content, '$.books[*]') as e(item)
  where
    b.path like '%books.json' 
)
, books_from_csv as
( select "Title" as title
       , "Genre" as genre
  from
    csv.books
)
select bj.title
     , bj.subtitle
     , bc.genre
     , bj.publisher
     , bj.date_of_publication
     , bj.description
     , bj.website
from   
  books_from_json bj
  left outer join
  books_from_csv bc
  on 
  bj.title = bc.title



Query Compute Instances in a specific Compartment from Oracle Cloud:


```
select
  inst.display_name,
  inst.id,
  inst.shape,
  inst.region,
  comp.name as compartment_name
from
  oci_core_instance inst
  inner join
    oci_identity_compartment comp
    on (inst.compartment_id = comp.id)
where comp.name = 'go-on-oci'
order by
  comp.name,
  inst.region,
  inst.shape
```  


 steampipe query oci-vms.sql --output json > oci_compute_instances.json
