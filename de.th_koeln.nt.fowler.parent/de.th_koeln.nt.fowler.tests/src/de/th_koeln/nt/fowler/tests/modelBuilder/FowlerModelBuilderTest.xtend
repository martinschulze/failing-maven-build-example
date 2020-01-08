package de.th_koeln.nt.fowler.tests.modelBuilder

import com.google.inject.Inject
import de.th_koeln.nt.fowler.fowler.Command
import de.th_koeln.nt.fowler.fowler.Event
import de.th_koeln.nt.fowler.fowler.FowlerFactory
import de.th_koeln.nt.fowler.fowler.State
import de.th_koeln.nt.fowler.fowler.Statemachine
import de.th_koeln.nt.fowler.fowler.Transition
import de.th_koeln.nt.fowler.generator.ModelBuilder
import de.th_koeln.nt.fowler.model.ModelFactory
import de.th_koeln.nt.fowler.tests.FowlerInjectorProvider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceImpl
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static de.th_koeln.nt.fowler.tests.ContainsEObject.containsEObject
import static de.th_koeln.nt.fowler.tests.EqualsEObject.equalsEObject
import static org.hamcrest.MatcherAssert.assertThat
import static org.hamcrest.Matchers.equalTo

@ExtendWith(InjectionExtension)
@InjectWith(typeof(FowlerInjectorProvider))
class FowlerModelBuilderTest {
	@Inject FowlerFactory astFactory
	@Inject ModelFactory modelFactory
	
	@Inject ModelBuilder modelBuilder
	
	ResourceImpl ast
	
	@BeforeEach
	def void createResource() {
		ast = new ResourceImpl(URI.createURI(""))
	}
	
	@Test
	def void eventsArePopulatedIntoModel() {
		val Event e1 = astFactory.createEvent => [name = "Event1"; code = "E1"]
		val Event e2 = astFactory.createEvent => [name = "Event2"; code = "E2"]
		
		val Statemachine sm = astFactory.createStatemachine
		ast.contents.add(sm)

		sm.events.add(e1)
		sm.events.add(e2)
		sm.resetEvents.add(e2)

		modelBuilder.populateDomainModel(ast)

		assertThat("Event is built into the Domainmodel",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createEvent => [name = "Event1"; code = "E1"]))
		assertThat("Event is built into the Domainmodel",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createEvent => [name = "Event2"; code = "E2"]))
	}

	@Test
	def void startStateIsCreated() {
		val State state1 = astFactory.createState => [name = "S1"]		
		val State state2 = astFactory.createState => [name = "S2"]		
		val Statemachine sm = astFactory.createStatemachine
		ast.contents.add(sm)

		sm.states.add(state1)
		sm.states.add(state2)

		modelBuilder.populateDomainModel(ast)

		assertThat("State1",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createState => [name = "S1"]))
		assertThat("State2",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createState => [name = "S2"]))
		assertThat("Start state",
			modelBuilder.domainModel.startState,
			equalsEObject(modelFactory.createState => [name = "S1"]))
		assertThat("There are only the two states", modelBuilder.domainModel.eAllContents.size, equalTo(2))
	} 
	
	@Test
	def void commandsAreCreatedAndWired() {
		val State state = astFactory.createState => [name = "S1"]		
		val Command command = astFactory.createCommand => [name = "Command1"; code = "C1"]
		state.actions.add(command)		
		val Statemachine sm = astFactory.createStatemachine
		ast.contents.add(sm)

		sm.states.add(state)
		sm.commands.add(command)

		modelBuilder.populateDomainModel(ast)

		assertThat("State1",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createState => [name = "S1";
				it.actions.add(modelFactory.createCommand => [name = "Command1"; code = "C1"])
			]
				
			))
	} 
	
	@Test
	def void transitionsAreWired() {
		val State state1 = astFactory.createState => [name = "S1"]		
		val State state2 = astFactory.createState => [name = "S2"]		
		val Event event1 = astFactory.createEvent => [name = "Event1"; code = "E1"]
		val Transition trans1 = astFactory.createTransition => [event = event1; state = state2]
		state1.transitions.add(trans1)

		val Statemachine sm = astFactory.createStatemachine
		ast.contents.add(sm)

		sm.states.add(state1)
		sm.states.add(state2)
		sm.events.add(event1)

		modelBuilder.populateDomainModel(ast)

		assertThat("State2",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createState => [name = "S2"]))
		assertThat("Event",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createEvent => [name = "Event1"; code = "E1"]))
		assertThat("State1",
			modelBuilder.domainModel.eAllContents,
			containsEObject(modelFactory.createState => [name = "S1"; it.outgoingTransitions.add(
				modelFactory.createTransition => [
					event = modelFactory.createEvent => [name="Event1"; code="E1"]
					endState = modelFactory.createState => [name = "S2"]
				]
			)]))
	} 
	
}
