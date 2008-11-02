////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  unit ThreadUtils                                                          //
//    Copyright 2006 by Arcana Technologies Incorporated                      //
//    Written By Jason Southwell                                              //
//                                                                            //
//  Description:                                                              //
//    This unit provides helper classes and functions to simplify threaded    //
//    programming.                                                            //
//                                                                            //
//    The ThreadRunner class and cooresponding global Run procedures make     //
//    it easy to launch delphi procedures asyncronously in a thread.  To      //
//    use, simply place the code which you wish to call in a thread into it's //
//    own procedure or method and call Run(procname) where procname is your   //
//    new procedure.                                                          //
//                                                                            //
//    The TThreadBatch class makes it simple to spead up many areas of your   //
//    code by asyncronously calling many loosly related functions at the same //
//    time and wait for all of them to complete before continuing.            //
//                                                                            //
//    This most often can speed up initialization code where you must         //
//    perform multiple functions which all must be completed before finishing //
//    the initialation, but they do not necessarily depend on each other.     //
//                                                                            //
//    For example, if you are filling in multiple lookups on a data entry     //
//    form, you can often fill all of these simulanously using the a          //
//    Threadbatch before showing the form.  If you have 6 lookup queries to   //
//    process and each takes about 1 second to return, then that can mean a   //
//    6 second delay in showing your form.  However, with a thread batch,     //
//    the delay will only ever be as long as the longest query, or about a    //
//    second.                                                                 //
//                                                                            //
//    This can help to improve Service, Web and Windows VCL applications.     //
//    It is important to remember (particularly in VCL applications) that you //
//    are operating in a threaded enviornment as soon as you implement the    //
//    ThreadRunner or ThreadBatch.  Therefore, any code in the proc sent to   //
//    the runner/batch must be thread safe.                                   //
//                                                                            //
//    See examples of how to deal with thread safety issues such as updating  //
//    a VCL gui.                                                              //
//                                                                            //
//									                                                          //
//  The latest version of this source code can always be found at:	          //
//    http://www.arcanatech.com/downloads/threadutils.zip		                  //
//									                                                          //
//  Updates:                                                                  //
//    10/18/2006 - Released the ThreadUtils unit to Open Source.              //
//                                                                            //
//  License:                                                                  //
//    This code is covered by the Mozilla Public License 1.1 (MPL 1.1)        //
//    Full text of this license can be found at                               //
//    http://www.opensource.org/licenses/mozilla1.1.html                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

unit ThreadUtils;

interface

uses Classes, SysUtils, Variants, SyncObjs;

type
  TThreadBatch = class;

  EThreadBatchFailure = Exception;

  TProcedure = procedure;
  TObjectMethod = procedure of object;
  TProcedureWithParams = procedure(Params : Variant);
  TObjectMethodWithParams = procedure(Params : Variant) of object;

  TThreadedProcedure = procedure(Sender : TThread);
  TThreadedObjectMethod = procedure(Sender : TThread) of object;
  TThreadedProcedureWithParams = procedure(Sender : TThread; Params : Variant);
  TThreadedObjectMethodWithParams = procedure(Sender : TThread; Params : Variant) of object;

  TErrorNotify = procedure(Sender : TObject; E : Exception) of object;

  TBatchItem = class(TThread)
  protected
    FOnError : TErrorNotify;
    FParams : Variant;
    FBatch : TThreadBatch;

    FProc : TProcedure;
    FMethod : TObjectMethod;
    FProcWP : TProcedureWithParams;
    FMethodWP : TObjectMethodWithParams;
    FTProc : TThreadedProcedure;
    FTMethod : TThreadedObjectMethod;
    FTProcWP : TThreadedProcedureWithParams;
    FTMethodWP : TThreadedObjectMethodWithParams;
    procedure Execute; override;
  public
    destructor Destroy; override;

    constructor Create(Batch : TThreadBatch; Proc : TProcedure; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TObjectMethod; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TProcedureWithParams; Params : Variant; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TObjectMethodWithParams; Params : Variant; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TThreadedProcedure; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TThreadedObjectMethod; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TThreadedProcedureWithParams; Params : Variant; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
    constructor Create(Batch : TThreadBatch; Proc : TThreadedObjectMethodWithParams; Params : Variant; Priority : TThreadPriority; ThreadError : TErrorNotify); overload; virtual;
  end;

  TThreadBatch = class(TObject)
  private
    FErrorList : TStringList;
    FErrorListCS : TCriticalSection;
    FBatchCnt : integer;
    FSleepInterval : integer;
    FOnError: TErrorNotify;
    FPrefixExceptions : boolean;
    procedure ThreadError(Sender : TObject; E : Exception);
  public
    constructor Create(PrefixExceptions : boolean = True); virtual;
    destructor Destroy; override;
    procedure WaitAndFree; virtual;

    procedure Run(Proc : TProcedure; Priority : TThreadPriority = tpNormal); overload;
    procedure Run(Proc : TObjectMethod; Priority : TThreadPriority = tpNormal); overload;
    procedure Run(Proc : TProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal); overload;
    procedure Run(Proc : TObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal); overload;
    procedure Wait;
    property SleepInterval : integer read FSleepInterval write FSleepInterval;
    property OnError : TErrorNotify read FOnError write FOnError;
  end;

  TThreadRunner = class(TThread)
  private
    FOnError : TErrorNotify;
    FParams : Variant;
    FBatch : TThreadBatch;
    FProc : TProcedure;
    FMethod : TObjectMethod;
    FProcWP : TProcedureWithParams;
    FMethodWP : TObjectMethodWithParams;
    FTProc : TThreadedProcedure;
    FTMethod : TThreadedObjectMethod;
    FTProcWP : TThreadedProcedureWithParams;
    FTMethodWP : TThreadedObjectMethodWithParams;
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    class procedure Run(Proc : TProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TThreadedProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TThreadedObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TThreadedProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
    class procedure Run(Proc : TThreadedObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
  end;

procedure RunAsThread(Proc : TProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;

procedure RunAsThread(Proc : TThreadedProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TThreadedObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TThreadedProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
procedure RunAsThread(Proc : TThreadedObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;

function ThreadBatchCount : integer;
function ThreadRunnerCount : integer;

implementation

var
  _ThreadBatchCount : integer;
  _ThreadRunnerCount : integer;

function ThreadBatchCount : integer;
begin
  Result := _ThreadBatchCount;
end;

function ThreadRunnerCount : integer;
begin
  Result := _ThreadRunnerCount;
end;

procedure RunAsThread(Proc : TProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Priority, OnError);
end;

procedure RunAsThread(Proc : TObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Priority, OnError);
end;

procedure RunAsThread(Proc : TProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Params, Priority, OnError);
end;

procedure RunAsThread(Proc : TObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Params, Priority, OnError);
end;

procedure RunAsThread(Proc : TThreadedProcedure; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Priority, OnError);
end;

procedure RunAsThread(Proc : TThreadedObjectMethod; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Priority, OnError);
end;

procedure RunAsThread(Proc : TThreadedProcedureWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Params, Priority, OnError);
end;

procedure RunAsThread(Proc : TThreadedObjectMethodWithParams; Params : Variant; Priority : TThreadPriority = tpNormal; OnError : TErrorNotify = nil); overload;
begin
  TThreadRunner.Run(Proc, Params, Priority, OnError);
end;


{ TBatchItem }

constructor TBatchItem.Create(Batch : TThreadBatch; Proc: TProcedure; Priority : TThreadPriority; ThreadError : TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := NULL;
  FBatch := Batch;
  FProc := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

constructor TBatchItem.Create(Batch : TThreadBatch; Proc: TObjectMethod; Priority : TThreadPriority; ThreadError : TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := NULL;
  FBatch := Batch;
  FMethod := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

constructor TBatchItem.Create(Batch: TThreadBatch; Proc: TProcedureWithParams;
  Params: Variant; Priority : TThreadPriority; ThreadError : TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := Params;
  FBatch := Batch;
  FProcWP := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

constructor TBatchItem.Create(Batch: TThreadBatch; Proc: TObjectMethodWithParams;
  Params: Variant; Priority : TThreadPriority; ThreadError : TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := Params;
  FBatch := Batch;
  FMethodWP := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

procedure TBatchItem.Execute;
begin
  try
    try
      if @FProc <> nil then
      begin
        FProc;
      end else if @FMethod <> nil then
      begin
        FMethod;
      end else if @FProcWP <> nil then
      begin
        FProcWP(FParams);
      end else if @FMethodWP <> nil then
      begin
        FMethodWP(FParams);
      end else if @FTProc <> nil then
      begin
        FTProc(Self);
      end else if @FTMethod <> nil then
      begin
        FTMethod(Self);
      end else if @FTProcWP <> nil then
      begin
        FTProcWP(Self, FParams);
      end else if @FTMethodWP <> nil then
      begin
        FTMethodWP(Self, FParams);
      end;
    except
      on e: Exception do
        FOnError(Self, E);
    end;
  finally
    if FBatch <> nil then
      dec(FBatch.FBatchCnt);
  end;
end;

constructor TBatchItem.Create(Batch: TThreadBatch; Proc: TThreadedObjectMethod;
  Priority: TThreadPriority; ThreadError: TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FBatch := Batch;
  FTMethod := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

constructor TBatchItem.Create(Batch: TThreadBatch; Proc: TThreadedProcedure;
  Priority: TThreadPriority; ThreadError: TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FBatch := Batch;
  FTProc := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

constructor TBatchItem.Create(Batch: TThreadBatch;
  Proc: TThreadedObjectMethodWithParams; Params: Variant;
  Priority: TThreadPriority; ThreadError: TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := Params;
  FBatch := Batch;
  FTMethodWP := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

destructor TBatchItem.Destroy;
begin
  dec(_ThreadBatchCount);
  inherited;
end;

constructor TBatchItem.Create(Batch: TThreadBatch;
  Proc: TThreadedProcedureWithParams; Params: Variant;
  Priority: TThreadPriority; ThreadError: TErrorNotify);
begin
  inherited Create(True);
  Self.Priority := Priority;
  FOnError := ThreadError;
  FParams := Params;
  FBatch := Batch;
  FTProcWP := Proc;
  FreeOnTerminate := True;
  inc(FBatch.FBatchCnt);
  inc(_ThreadBatchCount);
  Resume;
end;

{ TThreadBatch }

constructor TThreadBatch.Create(PrefixExceptions : boolean = True);
begin
  inherited Create;
  FSleepInterval := 10;
  FErrorList := TStringList.Create;
  FErrorListCS := TCriticalSection.Create;
  FPrefixExceptions := PrefixExceptions;
end;

destructor TThreadBatch.Destroy;
begin
  FErrorList.Free;
  FErrorListCS.Free;
  inherited;
end;

procedure TThreadBatch.Run(Proc: TProcedureWithParams; Params: Variant; Priority : TThreadPriority = tpNormal);
begin
  TBatchItem.Create(Self, Proc, Params, Priority, ThreadError);
end;

procedure TThreadBatch.Run(Proc: TObjectMethodWithParams; Params: Variant; Priority : TThreadPriority = tpNormal);
begin
  TBatchItem.Create(Self, Proc, Params, Priority, ThreadError);
end;

procedure TThreadBatch.ThreadError(Sender: TObject; E : Exception);
begin
  if Assigned(FOnError) then
    FonError(Self, E);
  FErrorListCS.Enter;
  try
    if not FPrefixExceptions then
      FErrorList.Add(e.Message)
    else
      FErrorList.Add(IntToStr(TThread(Sender).ThreadID)+': '+e.Message);
  finally
    FErrorListCS.Leave;
  end;
end;

procedure TThreadBatch.Wait;
begin
  while FBatchCnt > 0 do
    sleep(FSleepInterval);

  if FErrorList.Count > 0 then
    if not FPrefixExceptions then
      raise EThreadBatchFailure.Create(FErrorList.Text)
    else
      raise EThreadBatchFailure.Create('One or more threads in the batch failed to complete:'+#13#10#13#10+FErrorList.Text);
end;

procedure TThreadBatch.WaitAndFree;
begin
  try
    Wait;
  finally
    Free;
  end;
end;

procedure TThreadBatch.Run(Proc: TObjectMethod; Priority : TThreadPriority = tpNormal);
begin
  TBatchItem.Create(Self, Proc, Priority, ThreadError);
end;

procedure TThreadBatch.Run(Proc: TProcedure; Priority : TThreadPriority = tpNormal);
begin
  TBatchItem.Create(Self, Proc, Priority, ThreadError);
end;

{ TThreadRunner }

class procedure TThreadRunner.Run(Proc: TObjectMethod; Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FMethod := Proc;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TProcedure; Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FProc := Proc;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

constructor TThreadRunner.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  inc(_ThreadRunnerCount);
end;

destructor TThreadRunner.Destroy;
begin
  dec(_ThreadRunnerCount);
  inherited;
end;

procedure TThreadRunner.Execute;
begin
  try
    try
      if @FProc <> nil then
      begin
        FProc;
      end else if @FMethod <> nil then
      begin
        FMethod;
      end else if @FProcWP <> nil then
      begin
        FProcWP(FParams);
      end else if @FMethodWP <> nil then
      begin
        FMethodWP(FParams);
      end;
    except
      on e: Exception do
        if Assigned(FOnError) then
          FOnError(Self, E);
    end;
  finally
    if FBatch <> nil then
      dec(FBatch.FBatchCnt);
  end;
end;

class procedure TThreadRunner.Run(Proc: TObjectMethodWithParams;
  Params: Variant; Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FMethodWP := Proc;
  tr.FParams := Params;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TProcedureWithParams; Params: Variant;
  Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FProcWP := Proc;
  tr.FParams := Params;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TThreadedObjectMethod;
  Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FTMethod := Proc;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TThreadedProcedure;
  Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FTProc := Proc;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TThreadedObjectMethodWithParams;
  Params: Variant; Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FTMethodWP := Proc;
  tr.FParams := Params;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

class procedure TThreadRunner.Run(Proc: TThreadedProcedureWithParams;
  Params: Variant; Priority: TThreadPriority; OnError: TErrorNotify);
var
  tr : TThreadRunner;
begin
  tr := TThreadRunner.Create;
  tr.FTProcWP := Proc;
  tr.FParams := Params;
  tr.Priority := Priority;
  tr.FOnError := OnError;
  tr.Resume;
end;

end.
