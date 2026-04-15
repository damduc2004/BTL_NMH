# Test script to verify the fixes for product creation and feedback stats

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Testing Product & Feedback Fixes" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Wait for services
Start-Sleep -Seconds 3

# Test 1: Get all feedbacks to verify productName is included
Write-Host "`n[TEST 1] Get feedbacks - verify productName field exists" -ForegroundColor Yellow
try {
    $feedbacks = Invoke-WebRequest -Uri "http://localhost:8083/api/feedbacks" -Method GET -UseBasicParsing -TimeoutSec 5
    $data = $feedbacks.Content | ConvertFrom-Json
    
    if ($data.Count -gt 0) {
        $first = $data[0]
        Write-Host "  First feedback ID: $($first.id)" -ForegroundColor Cyan
        if ($first.PSObject.Properties.Name -contains "productName") {
            Write-Host "  ✓ productName field: '$($first.productName)'" -ForegroundColor Green
        } else {
            Write-Host "  ✗ productName field NOT FOUND!" -ForegroundColor Red
            Write-Host "  Available fields: $($first.PSObject.Properties.Name -join ', ')" -ForegroundColor Red
        }
        if ($first.PSObject.Properties.Name -contains "customerName") {
            Write-Host "  ✓ customerName field: '$($first.customerName)'" -ForegroundColor Green
        }
        Write-Host "  SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "  No feedbacks found - trying to get all categories first" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ ERROR: $_" -ForegroundColor Red
}

# Test 2: Get categories
Write-Host "`n[TEST 2] Get categories from product-service" -ForegroundColor Yellow
try {
    $categories = Invoke-WebRequest -Uri "http://localhost:8081/api/categories" -Method GET -UseBasicParsing -TimeoutSec 5
    $catData = $categories.Content | ConvertFrom-Json
    Write-Host "  Found $($catData.Count) categories" -ForegroundColor Green
    if ($catData.Count -gt 0) {
        Write-Host "  First category: ID=$($catData[0].id), Name=$($catData[0].name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ✗ ERROR: $_" -ForegroundColor Red
}

# Test 3: Try to create a product
Write-Host "`n[TEST 3] Create a product (admin action)" -ForegroundColor Yellow
try {
    $body = @{
        name = "iPhone 16 Test $(Get-Random)"
        price = 35999999
        stockQuantity = 10
        categoryId = 1
        fixedAttributes = @()
        extraAttributes = @()
    } | ConvertTo-Json -Compress
    
    $response = Invoke-WebRequest -Uri "http://localhost:8081/api/products" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $body `
        -UseBasicParsing `
        -TimeoutSec 5
    
    $product = $response.Content | ConvertFrom-Json
    Write-Host "  ✓ Product created successfully!" -ForegroundColor Green
    Write-Host "  Product ID: $($product.id)" -ForegroundColor Cyan
    Write-Host "  Product Name: $($product.name)" -ForegroundColor Cyan
    Write-Host "  Price: $($product.price)" -ForegroundColor Cyan
} catch {
    Write-Host "  ✗ ERROR creating product: $_" -ForegroundColor Red
}

# Test 4: Get products list
Write-Host "`n[TEST 4] Get all products" -ForegroundColor Yellow
try {
    $products = Invoke-WebRequest -Uri "http://localhost:8081/api/products" -Method GET -UseBasicParsing -TimeoutSec 5
    $prodData = $products.Content | ConvertFrom-Json
    Write-Host "  ✓ Found $($prodData.Count) products" -ForegroundColor Green
    if ($prodData.Count -gt 0) {
        Write-Host "  Sample: ID=$($prodData[0].id), Name=$($prodData[0].name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ✗ ERROR: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Test Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
