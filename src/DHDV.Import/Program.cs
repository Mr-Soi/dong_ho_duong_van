using Microsoft.Extensions.Configuration;
using DHDV.Import;

var config = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json", optional: true)
    .AddEnvironmentVariables()
    .Build();

string oldCs = Environment.GetEnvironmentVariable("OLD_CS")
    ?? config["ConnectionStrings:Old"]
    ?? throw new InvalidOperationException("Missing OLD_CS");

string newCs = Environment.GetEnvironmentVariable("NEW_CS")
    ?? config["ConnectionStrings:New"]
    ?? throw new InvalidOperationException("Missing NEW_CS");

string etl = Environment.GetEnvironmentVariable("ETL_CONFIG")
    ?? config["Etl:ConfigPath"]
    ?? throw new InvalidOperationException("Missing ETL_CONFIG");

Console.WriteLine($"[IMPORT] OLD={oldCs}\n[IMPORT] NEW={newCs}\n[IMPORT] ETL={etl}");
await Importer.RunAsync(oldCs, newCs, etl);
