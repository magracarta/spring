<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   <style type="text/css">
	   /* 리스트 템플릿에서 사용할 클래스 */
	   .myList-style {
	      text-align : left;
	      white-space : nowrap;
	   }
	   .myList-style .myList-col {
	      overflow: hidden;
	      text-overflow: ellipsis;
	      display:inline-block;
	   }
	   
	   </style>
	
	   <!-- 그리드 컬럼안 검색 스크립트 -->
	   <script type="text/javascript">
	   
	   var statusColumnLayout = [
		      {
		         dataField : "aui_status_cd",
		         headerText : "aui_status_cd",
		         width: 100,
		         style : "aui-center"
		      },
		      {
			     dataField : "aui_status_name",
			     headerText : "상태",
			     width: 100,
			     style : "aui-center"
			  },
		   	  {
		         dataField : "maker_name",
		         headerText : "메이커명",
		         width: 100,
		         style : "aui-center aui-popup"
		      }, {
		         dataField : "machine_name",
		         headerText : "장비명",
		         style : "aui-center aui-editable"
		      }
	   ];
	   
	   var smplStatusData = [
		   {"aui_status_cd" : "D", "aui_status_name" : "기본", "maker_name": "팝업 링크", "machine_name": "V270CP 에디터블" },
		   {"aui_status_cd" : "P", "aui_status_name" : "진행예정", "maker_name": "팝업 링크", "machine_name": "V270CP 에디터블" },
		   {"aui_status_cd" : "G", "aui_status_name" : "진행중", "maker_name": "팝업 링크", "machine_name": "V270CP 에디터블" },
		   {"aui_status_cd" : "R", "aui_status_name" : "반려", "maker_name": "팝업 링크", "machine_name": "V270CP 에디터블" },
		   {"aui_status_cd" : "C", "aui_status_name" : "완료", "maker_name": "팝업 링크", "machine_name": "V270CP 에디터블" },
	   ]
	   
	   function createAUIGridStatusSmpl(statusColumnLayout) {
		    var auiGridProps = {
		         editable : false,
		         softRemoveRowMode : false,
		         rowHeight : 30
			};
			auiGridStatusSmpl = AUIGrid.create("#auiGridStatusSmpl", statusColumnLayout, auiGridProps);
			AUIGrid.setGridData(auiGridStatusSmpl, smplStatusData);
	   }
	   
	   // 그리드 데이터
	   var gridData = [
	      {"idx":0, "part_no": "01-00001", "part_name": "부품1", "maker_cd_name": "얀마", "part_production_cd_name": "순정","part_mng_cd_name": "미수입","part_group_cd_name": "Ring Gear, Swing 링 기어"},
	      {"idx":1, "part_no": "02-00002", "part_name": "부품2", "maker_cd_name": "미얀마","part_production_cd_name": "중고","part_mng_cd_name": "수입","part_group_cd_name": "Bolt, Nut  제반 소형구성품"},
	      {"idx":2, "part_no": "03-00003", "part_name": "부품3", "maker_cd_name": "쿠보다","part_production_cd_name": "국산","part_mng_cd_name": "정상부품","part_group_cd_name": "Engine assy 엔진"},
	   ];

	   var gridData1 = [
	      {"idx":0, "maker_name": "겔", "machine_name": "V270CP", "machine_type_name": "스키드로다", "machine_sub_type_name": "3.5톤급이상","sale_yn": "Y","machine_plant_seq": "183", "grid_status" : "P"},
	      {"idx":1, "maker_name": "겔", "machine_name": "V270CP", "machine_type_name": "스키드로다", "machine_sub_type_name": "3.5톤급이상","sale_yn": "Y","machine_plant_seq": "183", "grid_status" : "S"},
	      {"idx":2, "maker_name": "겔", "machine_name": "V270CP", "machine_type_name": "스키드로다", "machine_sub_type_name": "3.5톤급이상","sale_yn": "Y","machine_plant_seq": "183", "grid_status" : "W"},
	   ];

	   // 사용자가 검색한 데이터
	   //var recentPartList = [];
	   // AUIGrid 생성 후 반환 ID
	   var auiGrid;
	   var auiGridMachine;
	   var auiGridStatusSmpl;
	   
	   $(document).ready(function() {
		  createAUIGridStatusSmpl(statusColumnLayout);
	      // AUIGrid 그리드를 생성합니다.
	      createAUIGrid(columnLayout);
	   });
	   
	   // AUIGrid 칼럼 설정
	   var columnLayout = [
	      {
	         dataField : "part_no",
	         headerText : "부품번호",
	         width: 180,
	         editRenderer : {
	            type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
	            conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
	               var param = {
	                     s_search_kind       : 'DEFAULT'
	               };
	               return fnGetPartSearchRenderer(dataField, param);
	               /* return item.part_name == '' ? fnGetPartSearchRenderer('display_info', param) : value; */
	            },
	         }
	      }, {
	         dataField : "part_name",
	         headerText : "부품명",
	         width: 100,
	         editable : false,
	         style : "aui-center"
	      }, {
	         dataField : "maker_cd_name",
	         headerText : "메이커",
	         width: 100,
	         editable : false,
	         style : "aui-center"
	      }, {
	         dataField : "part_production_cd_name",
	         headerText : "생산구분",
	         width: 100,
	         editable : false,
	         style : "aui-center"
	      }, {
	         dataField : "part_mng_cd_name",
	         headerText : "관리구분",
	         width: 100,
	         editable : false,
	         style : "aui-center"
	      }, {
	         dataField : "part_group_cd_name",
	         headerText : "분류명",
	         width: 275,
	         editable : false,
	         style : "aui-center"
	      }];

	   // AUIGrid 를 생성합니다.
	   function createAUIGrid(columnLayout) {
	      var auiGridProps = {
	         editable : true,
	         rowIdField : "idx",
	         softRemoveRowMode : false,
	         rowHeight : 30
	      };
	      // 실제로 #grid_wrap 에 그리드 생성
	      auiGrid = AUIGrid.create("#grid_wrap", columnLayout, auiGridProps);
	      // 에디팅 정상 종료 이벤트 바인딩
	      AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
	      // 에디팅 취소 이벤트 바인딩
	      AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
	      // 그리드 데이터 삽입
	      AUIGrid.setGridData(auiGrid, gridData);
	      
	      // 모델조회 그리드 (05/25 추가)
		   var gridProsMachine = {
		         editable : true,
		         rowIdField : "idx",
		         softRemoveRowMode : false,
		         rowHeight : 30				   
		   };
		   
		   var columnLayoutMachine = [
			   {
					headerText : "모델명", 
					dataField : "machine_name", 
					style : "aui-center",
			        editRenderer : {
			           type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
			           conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
			              var param = {
			                     s_sale_yn : 'Y'
			              };
			              return fnGetMachineSearchRenderer(dataField, param);
			           },
			        }					
			   },
			   {
					headerText : "메이커", 
					dataField : "maker_name", 
					style : "aui-center",
					editable : false,
			   },
			   {
					headerText : "기종", 
					dataField : "machine_type_name", 
					style : "aui-center",
					editable : false,
			   },
			   {
					headerText : "규격", 
					dataField : "machine_sub_type_name", 
					style : "aui-center",
					editable : false,
			   },
			   {
					dataField : "sale_yn", 
					visible : false
			   },
			   {
					dataField : "machine_plant_seq", 
					visible : false
			   },
		   ];
		   
		   auiGridMachine = AUIGrid.create("#auiGridMachine", columnLayoutMachine, gridProsMachine);
		   AUIGrid.setGridData(auiGridMachine, gridData1);
	       // 에디팅 정상 종료 이벤트 바인딩
	       AUIGrid.bind(auiGridMachine, "cellEditEnd", auiCellEditHandler1);
	       // 에디팅 취소 이벤트 바인딩
	       AUIGrid.bind(auiGridMachine, "cellEditCancel", auiCellEditHandler1);
		   $("#auiGridMachine").resize();
	   }
	   
	   function auiCellEditHandler1(event) {
		  switch(event.type) {
	      case "cellEditEnd" :
	         if(event.dataField == "machine_name") {
	            var machineItem = fnGetMachineItem(event.value);
	            console.log("machineItem : ", machineItem);
	            if(typeof machineItem === "undefined") {
	               return;
	            }
	            // 수정 완료하면, 나머지 필드도 같이 업데이트 함.
	            AUIGrid.updateRow(auiGridMachine, {
	            	machine_name : machineItem.machine_name,
	            	maker_name : machineItem.maker_name,
	            	machine_type_name : machineItem.machine_type_name,
	            	machine_sub_type_name : machineItem.machine_sub_type_name,
	            	machine_sub_type_name : machineItem.machine_sub_type_name,
	            	sale_yn : machineItem.sale_yn,
	            	machine_plant_seq : machineItem.machine_plant_seq
	            }, event.rowIndex);
	         }
	         break;
	      case "cellEditCancel" :
	         if(event.dataField == "machine_name") {
	            if(typeof event.item.machine_name == "undefined" || event.item.machine_name == "") {
	               //AUIGrid.removeRow(auiGrid, event.rowIndex);
	            }
	         }
	         break;
	      }
	   }


	   // 부품조회 편집 핸들러
	   function auiCellEditHandler(event) {
	      switch(event.type) {
	      case "cellEditEnd" :
	         if(event.dataField == "part_no") {
	            var partItem = fnGetPartItem(event.value);
	            if(typeof partItem === "undefined") {
	               return;
	            }
	            // 수정 완료하면, 나머지 필드도 같이 업데이트 함.
	            AUIGrid.updateRow(auiGrid, {
	               part_name : partItem.part_name,
	               maker_cd_name : partItem.maker_cd_name,
	               part_production_cd_name : partItem.part_production_cd_name,
	               part_mng_cd_name : partItem.part_mng_cd_name,
	               part_group_cd_name : partItem.part_group_cd_name
	            }, event.rowIndex);
	         }
	         break;
	      case "cellEditCancel" :
	         if(event.dataField == "part_no") {
	            if(typeof event.item.title == "undefined" || event.item.title == "") {
	               //AUIGrid.removeRow(auiGrid, event.rowIndex);
	            }
	         }
	         break;
	      }
	   };

	   // part_no 으로 검색해온 정보 아이템 반환.
	   function fnGetPartItem(part_no) {
	      var item;
	      $.each(recentPartList, function(n, v) {
	         if(v.part_no == part_no) {
	            item = v;
	            return false;
	         }
	      });
	      return item;
	   };

	   // machine_name 으로 검색해온 정보 아이템 반환.
	   function fnGetMachineItem(machine_name) {
	      var item;
	      $.each(recentMachineList, function(n, v) {
	         if(v.machine_name == machine_name) {
	            item = v;
	            return false;
	         }
	      });
	      return item;
	   };

	   function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "엑셀다운로드");
		}
	   
   </script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
   <!-- 메인 타이틀 -->
   		  <div class="main-title" style="width:900px;">
	         <h2>그리드상태</h2>
         </div>
         <div class="contents">
         	<div id="auiGridStatusSmpl" style="width:500px; height:200px;"></div>
         </div>
         <div class="main-title" style="width:900px;">
            <h2>부품조회</h2>
            <button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
         </div>
   <!-- /메인 타이틀 -->
         <div class="contents">
         	<div id="grid_wrap" style="width:900px; height:120px;"></div>
         </div>
         
         <div class="main-title" style="width:900px;">
	         <h2>모델조회</h2>
         </div>
         <div class="contents">
         	<div id="auiGridMachine" style="width:900px; height:120px;"></div>
         </div>
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>