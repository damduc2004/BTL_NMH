# Create test feedbacks with proper ratings for demo

$feedbackApi = "http://localhost:8083/api/feedbacks"

$testFeedbacks = @(
    @{ productId = 9; customerId = 3; comment = "Rất hài lòng"; overallRating = 5 },
    @{ productId = 8; customerId = 4; comment = "Product tốt"; overallRating = 4 },
    @{ productId = 1; customerId = 5; comment = "Chất lượng cao"; overallRating = 5 },
    @{ productId = 2; customerId = 3; comment = "Bình thường"; overallRating = 3 }
)

Write-Host "Creating test feedbacks with ratings..." -ForegroundColor Green

foreach ($fb in $testFeedbacks) {
    $body = $fb | ConvertTo-Json
    try {
        $resp = Invoke-WebRequest -Uri $feedbackApi -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body $body -UseBasicParsing -TimeoutSec 10
        $result = $resp.Content | ConvertFrom-Json
        Write-Host "  ✓ Created feedback ID=$($result.id), Rating=$($result.overallRating)" -ForegroundColor Cyan
    } catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nDone! Refresh http://localhost:8083/feedback/stats" -ForegroundColor Green
