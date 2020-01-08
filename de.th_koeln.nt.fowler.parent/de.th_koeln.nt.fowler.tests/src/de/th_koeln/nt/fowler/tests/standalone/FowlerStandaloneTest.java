package de.th_koeln.nt.fowler.tests.standalone;

import com.google.inject.Injector;

import de.th_koeln.nt.fowler.FowlerStandaloneSetup;

import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.junit.jupiter.api.Test;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.empty;

import java.util.List;

import org.eclipse.emf.common.util.URI;

public class FowlerStandaloneTest {

	@Test
	public void standaloneTest() {
		Injector injector = FowlerStandaloneSetup.doSetup();
		XtextResourceSet rs = injector.getInstance(XtextResourceSet.class);
		Resource resource = rs.getResource(URI.createFileURI("./standalone_test.std"), true);
		IResourceValidator validator = ((XtextResource)resource)
				.getResourceServiceProvider().getResourceValidator();
		EcoreUtil.resolveAll(resource);
		List<Issue> issues = validator.validate(
				resource, CheckMode.ALL, CancelIndicator.NullImpl);
		assertThat("There are no issues", issues, empty());
	}
}
