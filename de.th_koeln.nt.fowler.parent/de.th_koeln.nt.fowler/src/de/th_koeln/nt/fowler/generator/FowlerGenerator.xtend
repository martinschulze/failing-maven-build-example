package de.th_koeln.nt.fowler.generator

import de.th_koeln.nt.fowler.model.Statemachine
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.google.inject.Inject
import de.th_koeln.nt.fowler.model.State

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class FowlerGenerator extends AbstractGenerator {
	
	@Inject ModelBuilder modelBuilder
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		modelBuilder.populateDomainModel(resource)
		fsa.generateFile("fsm.dot", graphviz(modelBuilder.getDomainModel()))
	}
	
	def String graphviz(Statemachine statemachine) {
		'''
		digraph finite_state_machine {
			size="8,5"
			node [shape = record, style = rounded];

			«FOR state : statemachine.states»
				«state.name»[label="{«state.name»|«FOR action : state.actions»«action.code» «ENDFOR»}"];
			«ENDFOR»
			
			«FOR state : statemachine.states»
				«FOR transition : state.outgoingTransitions»
					«state.name» -> «transition.endState.name» [ label = "«transition.event.name»" ];
				«ENDFOR»
			«ENDFOR»

			node [shape = box, style = filled, color=azure2]
			resetEvents[label="Reset Events:\n«FOR resetEvent : statemachine.resetEvents»\n«resetEvent.name»«ENDFOR»"]
		}
		'''
	}
}
