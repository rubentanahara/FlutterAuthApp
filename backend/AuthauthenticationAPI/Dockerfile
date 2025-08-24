FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /source

COPY *.csproj .
RUN dotnet restore --verbosity minimal

COPY . .
RUN dotnet publish -c Release -o /app --no-restore --verbosity minimal

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app

RUN apk add --no-cache curl && \
    adduser -u 1000 -D -H -s /bin/sh appuser && \
    mkdir -p /app/data && \
    chown -R appuser:appuser /app

FROM base AS runtime

COPY --from=build --chown=appuser:appuser /app .

USER appuser

ENV ASPNETCORE_URLS=http://+:5062 \
    ASPNETCORE_ENVIRONMENT=Development \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    DOTNET_USE_POLLING_FILE_WATCHER=true

EXPOSE 5062

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5062/health || exit 1

ENTRYPOINT ["dotnet", "AuthauthenticationAPI.dll"]
