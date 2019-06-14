package de.th_koeln.nt.fowler.tests;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({de.th_koeln.nt.fowler.tests.ast.FowlerComplexParsingTest.class,
	de.th_koeln.nt.fowler.tests.ast.FowlerSimpleParsingTest.class,
	de.th_koeln.nt.fowler.tests.modelBuilder.FowlerModelBuilderTest.class,
	de.th_koeln.nt.fowler.tests.generator.GeneratorTest.class,
	de.th_koeln.nt.fowler.tests.integration.FowlerIntegration.class,
	de.th_koeln.nt.fowler.tests.standalone.FowlerStandaloneTest.class})
public class AllLanguageTests {

}
