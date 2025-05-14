import Testing
@testable import SampleApp

@Suite("CounterDependency Tests")
struct CounterDependencyTests {
    @Test("Mock dependency should increment correctly")
    func testMockIncrement() async {
        let mockDependency = MockCounterFeatureDependency()
        
        let result = await mockDependency.increment(int: 1)
        
        #expect(result == 2)
    }
    
    @Test("Mock dependency should decrement correctly")
    func testMockDecrement() async {
        let mockDependency = MockCounterFeatureDependency()
        
        let result = await mockDependency.decrement(int: 1)
        
        #expect(result == 0)
    }
    
    @Test("Real dependency should increment correctly")
    func testRealIncrement() async {
        let service = Service()
        let dependency = Dependencies(service: service)
        
        let result = await dependency.increment(int: 1)
        
        #expect(result == 2)
    }
    
    @Test("Real dependency should decrement correctly")
    func testRealDecrement() async {
        let service = Service()
        let dependency = Dependencies(service: service)
        
        let result = await dependency.decrement(int: 1)
        
        #expect(result == 0)
    }
} 