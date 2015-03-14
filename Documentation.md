# Introduction #
Delphi Threading Library (DTL) provides classes and functions which simplify creating asynchronous methods in Delphi.

A given method can be run in a background thread just by calling _Run_ on that method. By introducing a TThreadBatch class, applications can easily be sped up by executing multiple (independent) commands in parallel, which would usually be run in a sequential manner.

# Overview #

The ThreadRunner class and corresponding global Run procedures make it easy to launch Delphi procedures asynchronously in a thread.To use, simply place the code which you wish to call in a thread into it's own procedure or method and call _Run(procname)_ where procname is your new procedure.

The TThreadBatch class makes it simple to spead up many areas of your code by asyncronously calling many loosely related functions at the same time and wait for all of them to complete before continuing.

This most often can speed up initialization code where you must perform multiple functions which all must be completed before finishing the initialization, but they do not necessarily depend on each other.

For example, if you are filling in multiple lookups on a data entry form, you can often fill all of these simultaneously using the a Threadbatch before showing the form.If you have 6 lookup queries to process and each takes about 1 second to return, then that can mean a 6 second delay in showing your form.However, with a thread batch, the delay will only ever be as long as the longest query, or about a second.

This can help to improve Service, Web and Windows VCL applications. It is important to remember (particularly in VCL applications) that you are operating in a threaded environment as soon as you implement the ThreadRunner or ThreadBatch.Therefore, any code in the proc sent to the runner/batch must be thread safe.

See examples of how to deal with thread safety issues such as updating a VCL gui.