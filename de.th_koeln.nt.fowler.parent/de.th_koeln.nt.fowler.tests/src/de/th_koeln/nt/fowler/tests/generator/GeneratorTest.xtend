package de.th_koeln.nt.fowler.tests.generator

import com.google.inject.Inject
import de.th_koeln.nt.fowler.generator.FowlerGenerator
import de.th_koeln.nt.fowler.model.Command
import de.th_koeln.nt.fowler.model.Event
import de.th_koeln.nt.fowler.model.ModelFactory
import de.th_koeln.nt.fowler.model.State
import de.th_koeln.nt.fowler.model.Statemachine
import de.th_koeln.nt.fowler.model.Transition
import de.th_koeln.nt.fowler.tests.FowlerInjectorProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.hamcrest.MatcherAssert.assertThat
import static org.hamcrest.Matchers.*

@ExtendWith(InjectionExtension)
@InjectWith(typeof(FowlerInjectorProvider))
class GeneratorTest {
	@Inject ModelFactory modelFactory
	
	@Inject FowlerGenerator generator
	
	@Test
	def void emptyModelContainsHeaderAndFooter() {
		val Statemachine sm = modelFactory.createStatemachine
		checkHeaderAndFooter(sm)
		assertThat("", generator.graphviz(sm).split("\n").size, equalTo(9))
	}
	
	@Test
	def void stateIsGenerated() {
		val Statemachine sm = modelFactory.createStatemachine
		sm.states.add(modelFactory.createState => [name = "State1"])
		checkHeaderAndFooter(sm)

		assertThat("", generator.graphviz(sm), containsString("State1[label=\"{State1|}\"];"))
		assertThat("", generator.graphviz(sm).split("\n").size, equalTo(10))
	}

	@Test
	def void resetEventsAreCreated() {
		val Statemachine sm = modelFactory.createStatemachine
		val Event event1 = modelFactory.createEvent => [code = "E1" name = "Event1"]
		sm.resetEvents.add(event1)
		checkHeaderAndFooter(sm)

		assertThat("", generator.graphviz(sm), containsString("resetEvents[label=\"Reset Events:\\n\\nEvent1\"]"))
		assertThat("", generator.graphviz(sm).split("\n").size, equalTo(9))
	}
	
	
	@Test
	def void actionsAreContainedInStates() {
		val Statemachine sm = modelFactory.createStatemachine
		val Command command1 = modelFactory.createCommand => [code = "CM1" it.name = "Command1"]
		val Command command2 = modelFactory.createCommand => [code = "CM2" it.name = "Command2"]
		sm.commands.add(command1)
		sm.commands.add(command2)
		sm.states.add(modelFactory.createState => [
			name = "State1"
			actions.add(command1)
			actions.add(command2)
		])
		checkHeaderAndFooter(sm)

		assertThat("", generator.graphviz(sm), containsString("State1[label=\"{State1|CM1 CM2 }\"];"))
		assertThat("", generator.graphviz(sm).split("\n").size, equalTo(10))
	}
	
	@Test
	def void transitionsAreCreated() {
		val Statemachine sm = modelFactory.createStatemachine
		val Command command1 = modelFactory.createCommand => [code = "CM1" it.name = "Command1"]
		val Command command2 = modelFactory.createCommand => [code = "CM2" it.name = "Command2"]
		sm.commands.add(command1)
		sm.commands.add(command2)
		val Event event1 = modelFactory.createEvent => [code = "E1" name = "Event1"]
		sm.resetEvents.add(event1)
		val Event event2 = modelFactory.createEvent => [code = "E2" name = "Event2"]
		sm.events.add(event2)
		val State state1 = modelFactory.createState => [
			name = "State1"
			actions.add(command1)
		]
		val State state2 = modelFactory.createState => [
			name = "State2"
			actions.add(command2)
		]
		sm.states.add(state1)
		sm.states.add(state2)
		val Transition transition = modelFactory.createTransition => [
			event = event2
			startState = state1
			endState = state2
		]
		state1.outgoingTransitions.add(transition)
		checkHeaderAndFooter(sm)

		assertThat("", generator.graphviz(sm), containsString("State1[label=\"{State1|CM1 }\"];"))
		assertThat("", generator.graphviz(sm), containsString("State2[label=\"{State2|CM2 }\"];"))
		assertThat("", generator.graphviz(sm), containsString("State1 -> State2 [ label = \"Event2\" ];"))
		assertThat("", generator.graphviz(sm).split("\n").size, equalTo(12))
	}
	
	protected def void checkHeaderAndFooter(Statemachine sm) {
		assertThat("", generator.graphviz(sm), startsWith("digraph finite_state_machine {"))
		assertThat("", generator.graphviz(sm), containsString("size=\"8,5\""))
		assertThat("", generator.graphviz(sm), containsString("node [shape = record, style = rounded];"))
		assertThat("", generator.graphviz(sm), containsString("node [shape = box, style = filled, color=azure2]"))
		assertThat("", generator.graphviz(sm), endsWith("}\n"))
	}	
}


