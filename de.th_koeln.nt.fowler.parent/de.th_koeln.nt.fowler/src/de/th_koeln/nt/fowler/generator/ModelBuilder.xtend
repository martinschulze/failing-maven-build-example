package de.th_koeln.nt.fowler.generator

import de.th_koeln.nt.fowler.fowler.Command
import de.th_koeln.nt.fowler.fowler.Event
import de.th_koeln.nt.fowler.fowler.State
import de.th_koeln.nt.fowler.model.ModelFactory
import de.th_koeln.nt.fowler.model.Statemachine
import de.th_koeln.nt.fowler.model.Transition
import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource


class ModelBuilder {

	ModelFactory modelFactory

	Statemachine statemachine

	Map<String, de.th_koeln.nt.fowler.model.Event> events = new HashMap<String, de.th_koeln.nt.fowler.model.Event>
	Map<String, de.th_koeln.nt.fowler.model.Event> resetEvents = new HashMap<String, de.th_koeln.nt.fowler.model.Event>
	Map<String, de.th_koeln.nt.fowler.model.Command> commands = new HashMap<String, de.th_koeln.nt.fowler.model.Command>
	Map<String, de.th_koeln.nt.fowler.model.State> states = new HashMap<String, de.th_koeln.nt.fowler.model.State>

	new() {
		this.modelFactory = ModelFactory.eINSTANCE
	}

	def populateDomainModel(Resource ast) {
		this.statemachine = modelFactory.createStatemachine

		ast.resetEvents().forEach[preprocessResetEvents(it)]
		ast.filterFor(Event).forEach[addEvent(it as Event)]
		ast.filterFor(Command).forEach[addCommand(it as Command)]
		ast.filterFor(State).forEach[addState(it as State)]
		ast.filterFor(State).forEach[wireTransitions(it as State)]
		setStartState(ast.filterFor(State).head as State)
	}

	def setStartState(State state) {
		if (state !== null) {
			statemachine.startState = states.get(state.name)
		} else {
			statemachine.startState
		}
	}

	def preprocessResetEvents(Event event) {
		resetEvents.put(event.name, null)
	}

	def addEvent(Event event) {
		val de.th_koeln.nt.fowler.model.Event eventToAdd = modelFactory.createEvent
		eventToAdd.code = event.code
		eventToAdd.name = event.name
		if (!resetEvents.containsKey(eventToAdd.name)) {
			events.put(eventToAdd.name, eventToAdd)
			statemachine.events.add(eventToAdd)
		} else {
			resetEvents.replace(eventToAdd.name, eventToAdd)
			statemachine.resetEvents.add(eventToAdd)
		}
	}

	def addCommand(Command command) {
		val de.th_koeln.nt.fowler.model.Command commandToAdd = modelFactory.createCommand
		commandToAdd.code = command.code
		commandToAdd.name = command.name
		commands.put(commandToAdd.name, commandToAdd)
		statemachine.commands.add(commandToAdd)
	}

	def addState(State state) {
		val de.th_koeln.nt.fowler.model.State stateToAdd = modelFactory.createState
		stateToAdd.name = state.name
		stateToAdd.actions.addAll(
			state.actions.map [ original |
				commands.filter [ key, value |
					key == original.name
				].values
			].flatten
		)
		states.put(stateToAdd.name, stateToAdd)
		statemachine.states.add(stateToAdd)
	}

	def wireTransitions(State state) {
		state.transitions.forEach [
			if (events.containsKey(it.event.name)) {
				val Transition transitionToAdd = modelFactory.createTransition
				transitionToAdd.startState = states.get(state.name)
				transitionToAdd.endState = states.get(it.state.name)
				transitionToAdd.event = events.get(it.event.name)
				transitionToAdd.startState.outgoingTransitions.add(transitionToAdd)
			}
		]
	}

	def filterFor(Resource ast, Class<?> instanceClass) {
		ast.allContents.filter[it.eClass.instanceClass.equals(instanceClass)]
	}

	def EList<Event> resetEvents(Resource ast) {
		ast.allContents.toIterable.filter(typeof(de.th_koeln.nt.fowler.fowler.Statemachine)).get(0).resetEvents
	}

	def Statemachine getDomainModel() {
		statemachine
	}

}
