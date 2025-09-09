# root/Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ./src/DHDV.Web/*.csproj ./src/DHDV.Web/
RUN dotnet restore ./src/DHDV.Web/DHDV.Web.csproj
COPY ./src ./src
RUN dotnet publish ./src/DHDV.Web/DHDV.Web.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet","DHDV.Web.dll"]
