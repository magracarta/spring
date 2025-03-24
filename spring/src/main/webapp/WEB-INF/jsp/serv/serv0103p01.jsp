<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 공구함관리
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-17 18:14:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();

		 //라디오 버튼 변경시 이벤트
        $("input[name^='box']:radio").change(function () {
        	      	
        	var radioVal = $(this).val();
			if (radioVal == "N") {

				console.log(this);
				var radioName = this.name;
				var param = {
						
						s_center_org_code : $M.getValue("center_org_code"),
						s_svc_tool_box_cd : radioName.replace("box","")
						
				};
				$M.goNextPageAjax(this_page + "/toolBoxChkCount", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
	
						}
						else{
							
							$('input:radio[name=' + radioName + ']:input[value=' + "Y" + ']').prop("checked", true);
							
						}
					}
				);
				
			}
                                
         });
		

	});
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				dataField : "org_code", 
				visible : false
			},
			{ 
				headerText : "센터", 
				dataField : "org_name", 
				style : "aui-center aui-popup",
				editable : false
			},
			{
				headerText : "센터설비", 
				dataField : "box16", 
				style : "aui-center",
				editable : false,
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
					var retStr = "";
					if(value=="Y"){
						retStr = "O";
					}
					else{
						retStr = "X";
					}
					return retStr;
				}
			},
			{ 
				headerText : "특수공구", 
				dataField : "box17", 
				style : "aui-center ",
				editable : false,
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
					var retStr = "";
					if(value=="Y"){
						retStr = "O";
					}
					else{
						retStr = "X";
					}
					return retStr;
				}
			},
			{ 
				headerText : "마스터공구", 
				dataField : "box18", 
				style : "aui-center",
				editable : false,
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
					var retStr = "";
					if(value=="Y"){
						retStr = "O";
					}
					else{
						retStr = "X";
					}
					return retStr;
				}				
			},
			{ 
				headerText : "공구함", 
				dataField : "", 
				style : "aui-center",
				children : [
					{
						dataField : "box01",
						headerText : "1",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}						
					}, 
					{
						dataField : "box02",
						headerText : "2",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}						
					},
					{
						dataField : "box03",
						headerText : "3",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}						
					},
					{
						dataField : "box04",
						headerText : "4",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box05",
						headerText : "5",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box06",
						headerText : "6",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box07",
						headerText : "7",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box08",
						headerText : "8",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box09",
						headerText : "9",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box10",
						headerText : "10",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box11",
						headerText : "11",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					},
					{
						dataField : "box12",
						headerText : "12",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					}
				]
			},
			{ 
				headerText : "서비스차량", 
				dataField : "f", 
				style : "aui-center",
				children : [
					{
						dataField : "box13",
						headerText : "1",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					}, 
					{
						dataField : "box14",
						headerText : "2",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					}, 
					{
						dataField : "box15",
						headerText : "3",
						width : "3%",
						editable : false,
						labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
							var retStr = "";
							if(value=="Y"){
								retStr = "O";
							}
							else{
								retStr = "X";
							}
							return retStr;
						}
					}, 
				]
			},
			{ 
				headerText : "변경자", 
				dataField : "upt_mem_name", 
				editable : false,
				style : "aui-center",
			},
			{ 
				headerText : "변경일", 
				dataField : "upt_date", 
				editable : false,
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${allCenterToolBoxList});
		
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "org_name" ) {
				
				$M.setValue("center_org_code",event.item.org_code);
				goSearch();
			}
		});	
		
		$("#auiGrid").resize();
	}	
	
	// 조회
	function goSearch() {
		
		
		var param = {
				s_center_org_code 	: $M.getValue("center_org_code"),

		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
			function (result) {
				if (result.success) {
				
			
					$("#span_org_name").html(result.org_name);
					$('input:radio[name=box01]:input[value=' + result.box01 + ']').prop("checked", true);
					$('input:radio[name=box02]:input[value=' + result.box02 + ']').prop("checked", true);
					$('input:radio[name=box03]:input[value=' + result.box03 + ']').prop("checked", true);
					$('input:radio[name=box04]:input[value=' + result.box04 + ']').prop("checked", true);
					$('input:radio[name=box05]:input[value=' + result.box05 + ']').prop("checked", true);
					$('input:radio[name=box06]:input[value=' + result.box06 + ']').prop("checked", true);
					$('input:radio[name=box07]:input[value=' + result.box07 + ']').prop("checked", true);
					$('input:radio[name=box08]:input[value=' + result.box08 + ']').prop("checked", true);
					$('input:radio[name=box09]:input[value=' + result.box09 + ']').prop("checked", true);
					$('input:radio[name=box10]:input[value=' + result.box10 + ']').prop("checked", true);
					$('input:radio[name=box11]:input[value=' + result.box11 + ']').prop("checked", true);
					$('input:radio[name=box12]:input[value=' + result.box12 + ']').prop("checked", true);
					$('input:radio[name=box13]:input[value=' + result.box13 + ']').prop("checked", true);
					$('input:radio[name=box14]:input[value=' + result.box14 + ']').prop("checked", true);
					$('input:radio[name=box15]:input[value=' + result.box15 + ']').prop("checked", true);
					$('input:radio[name=box16]:input[value=' + result.box16 + ']').prop("checked", true);
					$('input:radio[name=box17]:input[value=' + result.box17 + ']').prop("checked", true);
					$('input:radio[name=box18]:input[value=' + result.box18 + ']').prop("checked", true);

				}
			}
		);
	}
	
	
	// 저장
	function goSave() {
		
		var frm = document.main_form;	
		
		console.log(frm);
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
	}
	
	// 닫기
    function fnClose() {
    	window.close();
    }
	

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        	<input type="hidden" id="center_org_code" 	name="center_org_code" value="${inputParam.center_org_code}" />

        	
<!-- 폼테이블1 -->					
			<div>
<!-- 전 센터 공구함 현황 -->
				<div class="title-wrap">
					<h4>전 센터 공구함 현황</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
<!-- /전 센터 공구함 현황 -->
			</div>
<!-- /폼테이블1 -->
<!-- 폼테이블2 -->
			<div>
<!-- 평택센터 공구함 관리 -->
				<div class="title-wrap mt10">
					<h4>
						<span class="text-primary" id="span_org_name" name="span_org_name" >${inputParam.center_org_name}</span>
						공구함 관리
					</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="36px">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">센터설비</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box16" value="Y"  ${centerToolBoxMap.box16 == 'Y'? 'checked="checked"' : ''}  disabled>
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box16" value="N"  ${centerToolBoxMap.box16  == 'N'? 'checked="checked"' : ''} disabled>
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th rowspan="6" class="th-skyblue text-center">공<br>구<br>함</th>
							<th class="text-right">공구함1</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box01" value="Y"  ${centerToolBoxMap.box01 == 'Y'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box01" value="N" ${centerToolBoxMap.box01  == 'N'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함7</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box07" value="Y"  ${centerToolBoxMap.box07 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box07" value="N" ${centerToolBoxMap.box07 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>
						<tr>
							<th class="text-right">특수공구</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box17" value="Y"   ${centerToolBoxMap.box17 == 'Y'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"   name="box17" value="N" ${centerToolBoxMap.box17 == 'N'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함2</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box02" value="Y"  ${centerToolBoxMap.box02 == 'Y'? 'checked="checked"' : ''}>
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box02" value="N"  ${centerToolBoxMap.box02 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함8</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box08" value="Y"  ${centerToolBoxMap.box08 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box08" value="N"  ${centerToolBoxMap.box08 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>
						<tr>
							<th class="text-right">마스터공구함</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box18" value="Y"   ${centerToolBoxMap.box18 == 'Y'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box18" value="N" ${centerToolBoxMap.box18 == 'N'? 'checked="checked"' : ''} disabled >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함3</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box03" value="Y"  ${centerToolBoxMap.box03 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box03" value="N"  ${centerToolBoxMap.box03 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함9</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box09" value="Y"  ${centerToolBoxMap.box09 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box09" value="N"   ${centerToolBoxMap.box09 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>
						<tr>
							<th class="text-right">서비스차량1</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box13"  value="Y"  ${centerToolBoxMap.box13 == 'Y'? 'checked="checked"' : ''}  disabled>
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio"  name="box13"  value="N" ${centerToolBoxMap.box13 == 'N'? 'checked="checked"' : ''} disabled>
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함4</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box04"  value="Y"  ${centerToolBoxMap.box04 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box04"  value="N"  ${centerToolBoxMap.box04 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함10</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box10"  value="Y"  ${centerToolBoxMap.box10 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box10" value="N"  ${centerToolBoxMap.box10 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>
						<tr>
							<th class="text-right">서비스차량2</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box14"   value="Y"  ${centerToolBoxMap.box14 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box14"  value="N" ${centerToolBoxMap.box14 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함5</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box05"   value="Y" ${centerToolBoxMap.box05 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box05"   value="N" ${centerToolBoxMap.box05 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함11</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box11"   value="Y" ${centerToolBoxMap.box11 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box11"  value="N" ${centerToolBoxMap.box11 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>
						<tr>
							<th class="text-right">서비스차량3</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box15"  value="Y"  ${centerToolBoxMap.box15 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box15"  value="N" ${centerToolBoxMap.box15 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함6</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box06"   value="Y" ${centerToolBoxMap.box06 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box06"  value="N" ${centerToolBoxMap.box06 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
							<th class="text-right">공구함12</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box12"  value="Y"  ${centerToolBoxMap.box12 == 'Y'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="box12"  value="N" ${centerToolBoxMap.box12 == 'N'? 'checked="checked"' : ''} >
									<label class="form-check-label">사용안함</label>
								</div>
							</td>						
						</tr>											
					</tbody>
				</table>
<!-- /평택센터 공구함 관리 -->
			</div>
<!-- /폼테이블2 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>