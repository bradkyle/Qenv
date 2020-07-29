import pandas;
import pyarrow;
import pyarrow.parquet as parquet;
import json

def getDatasetJ(paths):
  paths=json.loads(paths);
  return parquet.ParquetDataset(paths).read().to_pandas();

def getDataset(paths):
  return parquet.ParquetDataset(paths).read().to_pandas();

def getDatasetColumnNames(paths):
  return (parquet.ParquetDataset(paths).schema).names;

def getTable(file):
  return (parquet.read_table(file)).to_pandas();

def setTable(file, table):
  table=pandas.DataFrame(table);
  table=pyarrow.Table.from_pandas(table);
  parquet.write_table(table, file);
  return file;

def getColumnNames(file):
  return (parquet.read_schema(file)).names;

def getColumns(file, cols):
  table=parquet.read_table(file, columns=cols);
  return (table.to_pandas()).to_dict('list');

def getColumnCustom(file, col, conversion): 
  table=parquet.read_table(file, columns=[col]);
  table=table.to_pandas();
  exec(conversion);
  return table.to_dict('list');