﻿unit LUX.Win.Messaging;

interface //#################################################################### ■

uses System.Generics.Collections,
　　 FMX.Platform,
     Winapi.Windows;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TMessageEvent = reference to procedure( const MSG_:TMSG );

     TMessageItem = TPair<UINT,TMessageEvent>;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMessageEventList

     TMessageEventList = TDictionary<UINT,TMessageEvent>;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMessageService

     TMessageService = class( TInterfacedObject, IFMXApplicationService )
     private
       class var OldAppService :IFMXApplicationService;
       class var NewAppService :IFMXApplicationService;
       ///// メソッド
       class procedure AddPlatformService;
     protected
       class var _EventList :TMessageEventList;
     public
       class constructor Create;
       class destructor Destroy;
       ///// メソッド
       procedure Run;
       function HandleMessage :Boolean;
       procedure WaitMessage;
       function GetDefaultTitle :String;
       function GetTitle :String;
       procedure SetTitle( const Value_:String );
       function GetVersionString :String;
       procedure Terminate;
       function Terminating :Boolean;
       function Running :Boolean;
       ///// プロパティ
       class property EventList    :TMessageEventList read   _EventList                   ;
             property DefaultTitle :String            read GetDefaultTitle                ;
             property Title        :String            read GetTitle         write SetTitle;
             property AppVersion   :String            read GetVersionString               ;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMessageService

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

class constructor TMessageService.Create;
begin
     inherited;

     _EventList := TMessageEventList.Create;
end;

class destructor TMessageService.Destroy;
begin
     _EventList.Free;

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

class procedure TMessageService.AddPlatformService;
begin
     if TPlatformServices.Current.SupportsPlatformService
        ( IFMXApplicationService, IInterface( OldAppService ) ) then
     begin
          TPlatformServices.Current.RemovePlatformService( IFMXApplicationService );

          NewAppService := TMessageService.Create;

          TPlatformServices.Current.AddPlatformService( IFMXApplicationService, NewAppService );
     end;
end;

procedure TMessageService.Run;
begin
     OldAppService.Run;
end;

function TMessageService.HandleMessage :Boolean;
var
   M :TMsg;
   E :TMessageItem;
begin
     Result := PeekMessage( M, 0, 0, 0, PM_REMOVE );

     if Result then
     begin
          for E in _EventList do
          begin
               if M.Message = E.Key then
               begin
                    E.Value( M );  Exit;
               end;
          end;

          TranslateMessage( M );
          DispatchMessage ( M );
     end;

     OldAppService.HandleMessage;
     OldAppService.HandleMessage;
end;

procedure TMessageService.WaitMessage;
begin
     OldAppService.WaitMessage;
end;

function TMessageService.GetDefaultTitle :String;
begin
     Result := OldAppService.GetDefaultTitle;
end;

function TMessageService.GetTitle :String;
begin
     Result := OldAppService.GetTitle;
end;

procedure TMessageService.SetTitle( const Value_:String );
begin
     OldAppService.SetTitle( Value_ );
end;

function TMessageService.GetVersionString: String;
begin
     Result := OldAppService.GetVersionString;
end;

procedure TMessageService.Terminate;
begin
     OldAppService.Terminate;
end;

function TMessageService.Terminating :Boolean;
begin
     Result := OldAppService.Terminating;
end;

function TMessageService.Running :Boolean;
begin
     Result := OldAppService.Running;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     TMessageService.AddPlatformService;

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■