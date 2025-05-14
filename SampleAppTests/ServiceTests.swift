import Testing
@testable import SampleApp

@Suite("Service Tests")
struct ServiceTests {
    @Test("Service should increment correctly")
    func testIncrement() async {
        let service = Service()
        
        let result = await service.increment(int: 1)
        
        #expect(result == 2)
    }
    
    @Test("Service should decrement correctly")
    func testDecrement() async {
        let service = Service()
        
        let result = await service.decrement(int: 1)
        
        #expect(result == 0)
    }
    
    @Test("Service should handle negative numbers")
    func testNegativeNumbers() async {
        let service = Service()
        
        let incrementResult = await service.increment(int: -1)
        let decrementResult = await service.decrement(int: -1)
        
        #expect(incrementResult == 0)
        #expect(decrementResult == -2)
    }
    
    @Test("Service should handle zero")
    func testZero() async {
        let service = Service()
        
        let incrementResult = await service.increment(int: 0)
        let decrementResult = await service.decrement(int: 0)
        
        #expect(incrementResult == 1)
        #expect(decrementResult == -1)
    }
} 