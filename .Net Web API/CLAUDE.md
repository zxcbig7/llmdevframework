# ASP.NET Core Web API 開發規範

<system_context>
ASP.NET Core 8+ Web API 後端開發守則。
分層架構：Controllers → Services → Repositories → DbContext / Oracle。
JWT 認證、async/await、DI 為預設。
</system_context>

<critical_notes>
- MUST 用 constructor injection，NEVER 用 service locator (`serviceProvider.GetService<T>()`)
- MUST 所有 I/O 操作 async/await，方法名加 `Async` 後綴
- NEVER 在 controller 寫 business logic（只處理 HTTP 關注點）
- NEVER 在 constructor 內 `await` 或長時間 task
- NEVER 直接回傳 entity，一律經 DTO mapping
- NEVER `SELECT *` 或 `dbContext.X.ToList()` 不加 filter
- ALWAYS 用 global exception middleware，不要散在各 action 寫 try-catch
- ALWAYS 用 `CancellationToken` 接收並向下傳遞
</critical_notes>

<file_map>
src/Api/                - Controllers、middleware、Program.cs、appsettings
src/Application/        - Services、DTOs、validators、interfaces
src/Domain/             - Entities、value objects、domain events
src/Infrastructure/     - Repositories、DbContext、external clients
tests/UnitTests/        - 單元測試
tests/IntegrationTests/ - 整合測試（WebApplicationFactory）
</file_map>

<paved_path>
- 命名：PascalCase class/method/property、camelCase 區域變數/參數、`_camelCase` private field、PascalCase constant
- Async method 一律 `XxxAsync` 後綴
- Controller 薄、Service 厚、Repository 只處理 persistence
- DI lifetime 預設 Scoped，無狀態 stateless 才用 Singleton，極短生命週期才 Transient
- Service registration 拆 extension method（`services.AddXxx()`）避免 Program.cs 爆炸
- 環境設定分檔：`appsettings.{Environment}.json`，secret 用 user-secrets / env var
- Validation 用 FluentValidation 或 DataAnnotation + ActionFilter
- Logging 注入 `ILogger<T>`，用 structured log（`_logger.LogInformation("User {UserId} ...", id)`）
</paved_path>

<patterns>
**Controller**
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    public UsersController(IUserService userService) => _userService = userService;

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<UserDto>> GetByIdAsync(Guid id, CancellationToken ct)
    {
        var user = await _userService.GetByIdAsync(id, ct);
        return user is null ? NotFound() : Ok(user);
    }
}
```

**Routing**
- 用名詞複數：`/api/users` 不是 `/api/getUsers`
- HTTP verbs 表達動作：GET / POST / PUT / PATCH / DELETE
- Route constraint：`{id:guid}` / `{id:int}`

**Error handling**
- 全域 middleware 攔截 exception → 回 ProblemDetails (RFC 7807)
- 已知 domain error 用 Result pattern 或 自訂 exception type

**DI lifetime 速查**
- DbContext / Repository / 多數 Service → Scoped
- Pure helper / config → Singleton
- 含可變狀態且短期 → Transient
- Singleton 要拿 Scoped → 注入 `IServiceScopeFactory` 自建 scope
</patterns>

<common_tasks>
- 加 endpoint → Controller method + Service interface/impl + DTO
- 加 entity → Domain entity + DbContext DbSet + Migration
- 加 validation → FluentValidation Validator class，DI 註冊
- 加新 dependency → `Application/Interfaces/IXxx.cs` + `Infrastructure/Xxx.cs` + extension method 註冊
</common_tasks>

<example>
- Global exception middleware → `src/Api/Middleware/ExceptionMiddleware.cs`, search:`InvokeAsync`
- DI extension → `src/Api/Extensions/ServiceExtensions.cs`, search:`ConfigureSwagger`
- Result pattern → `src/Application/Common/Result.cs`, search:`class Result`
- ActionFilter validation → `src/Api/Filters/ModelValidationAttribute.cs`, search:`OnActionExecuting`
</example>

<hatch>
- 真的要在 Singleton 用 Scoped service → 用 `IServiceScopeFactory.CreateScope()`
- 簡單 CRUD 用 Minimal API（`app.MapGet`），複雜業務仍用 Controller
- 跨層需要傳遞額外資料 → 用 DTO，不要直接拋 entity
</hatch>

<fatal_implications>
- NEVER 在 controller / service 寫 raw SQL string concat（SQL injection）
- NEVER 把 connection string、JWT secret commit 進 repo
- NEVER `.Result` / `.Wait()` 對 async method（deadlock）
- NEVER 在 loop 裡 `await`（用 `Task.WhenAll` 平行）
- NEVER 把 `DbContext` 註冊成 Singleton
- NEVER 把 entity 序列化回 client（lazy loading 會觸發 N+1）
</fatal_implications>
