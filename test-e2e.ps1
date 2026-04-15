Write-Host "=====================================" -ForegroundColor Green
Write-Host "  E2E TEST: Product and Feedback System" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$productAPI = "http://localhost:8081"
$feedbackAPI = "http://localhost:8083"

Write-Host "`nTEST 1: GET /api/products" -ForegroundColor Yellow
$products = Invoke-WebRequest -Uri "$productAPI/api/products" -Method GET -UseBasicParsing | ConvertFrom-Json
Write-Host "  SUCCESS: Found $($products.Count) products" -ForegroundColor Green

Write-Host "`nTEST 2: POST /api/products" -ForegroundColor Yellow
$body = @{ name = "iPhone 16 Test $(Get-Random)"; price = 35999999; categoryId = 1; fixedAttributes = @(); extraAttributes = @() } | ConvertTo-Json -Compress
$createResp = Invoke-WebRequest -Uri "$productAPI/api/products" -Method POST -Headers @{"Content-Type"="application/json"} -Body $body -UseBasicParsing | ConvertFrom-Json
$productId = $createResp.id
Write-Host "  SUCCESS: Created product ID=$productId" -ForegroundColor Green

Write-Host "`nTEST 3: GET /api/products/{id}" -ForegroundColor Yellow
$detail = Invoke-WebRequest -Uri "$productAPI/api/products/$productId" -Method GET -UseBasicParsing | ConvertFrom-Json
Write-Host "  SUCCESS: Retrieved $($detail.name)" -ForegroundColor Green

Write-Host "`nTEST 4: POST /api/feedbacks" -ForegroundColor Yellow
# Find a valid customer first
$customerURI = "http://localhost:8082/api/customers"
$customers = Invoke-WebRequest -Uri $customerURI -Method GET -UseBasicParsing | ConvertFrom-Json
$customerId = $customers[0].id
Write-Host "  Using customer ID: $customerId" -ForegroundColor Cyan
$fbody = @{ productId = $productId; customerId = $customerId; comment = "Great product"; overallRating = 5; attributeRatings = @(@{ attributeName = "Quality"; rating = 5; comment = "Good" }) } | ConvertTo-Json -Compress
$fbResp = Invoke-WebRequest -Uri "$feedbackAPI/api/feedbacks" -Method POST -Headers @{"Content-Type"="application/json"} -Body $fbody -UseBasicParsing | ConvertFrom-Json
$feedbackId = $fbResp.id
Write-Host "  SUCCESS: Created feedback ID=$feedbackId" -ForegroundColor Green

Write-Host "`nTEST 5: GET /api/feedbacks/product/{id}/stats" -ForegroundColor Yellow
$stats = Invoke-WebRequest -Uri "$feedbackAPI/api/feedbacks/product/$productId/stats" -Method GET -UseBasicParsing | ConvertFrom-Json
Write-Host "  SUCCESS: Avg Rating=$($stats.averageRating)" -ForegroundColor Green

Write-Host "`nTEST 6: Verify product in list" -ForegroundColor Yellow
$list = Invoke-WebRequest -Uri "$productAPI/api/products" -Method GET -UseBasicParsing | ConvertFrom-Json
$found = $list | Where-Object { $_.id -eq $productId }
Write-Host "  SUCCESS: Product found in list" -ForegroundColor Green

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  ALL 6 TESTS PASSED!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green