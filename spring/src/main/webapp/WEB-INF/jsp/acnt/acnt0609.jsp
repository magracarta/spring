<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인센티브평가 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2021-07-26 14:31:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var columnDataList;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			
			// 연도 변경시 그룹선택 변경
			$("#s_incen_year").change(function(){
				changeSelectList($M.getValue("s_incen_year"));
			});
			init();
		});
		
		function init(){
			if("${showYn}" != "Y") {
                $("#s_org_code").prop("disabled", true);
            }
			
			goSearch();
		}
		
		// 그리드 생성
		function createAUIGrid(){
			var gridPros = {
					rowIdField : "_$uid",
					showRowNumColumn: true,
					softRemoveRowMode : true,
					editable : true,
			};
			
			auiGrid = AUIGrid.create("#auiGrid", [], gridPros);
			
 			AUIGrid.bind(auiGrid, "cellEditBegin", cellEditHandler);
 			AUIGrid.bind(auiGrid, "cellEditEndBefore", cellEditHandler);
			
		}
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}
		
		
		// 셀 행동 컨트롤
		function cellEditHandler(event){
			var secureUser = $M.getValue("secure_mem_no");
			switch(event.type){
				case "cellEditBegin":
					for(var i=0; i<columnDataList.length;i++){
						if(event.dataField == columnDataList[i].incen_eval_cd_column && columnDataList[i].auto_cal_yn == 'N'){
							if(event.item.mng_mem_no != secureUser && event.item.boss_mem_no != secureUser && event.item.last_mem_no != secureUser  && "${page.fnc.F03120_001}" != "Y"){
								return false;
							}
						}
					}
					
					if(event.dataField == "boss_eval_point"){
						if(event.item.boss_mem_no != secureUser){
							return false;
						}
					}else if(event.dataField == "mng_eval_point"){
						if(event.item.mng_mem_no != secureUser){
							return false;
						}
					}else if(event.dataField == "last_eval_point"){
						if(event.item.last_mem_no != secureUser){
							return false;
						}
					}else if(event.dataField == "rep_adjust_point"){
						if("${page.fnc.F03120_002}" != "Y"){
							return false;
						}
					}
					break;
				case "cellEditEndBefore" :
					if(event.value == event.oldValue){
						return event.oldValue;
					}
					var now_total_point = event.item.total_point;
					var new_total_point = $M.toNum(now_total_point) + $M.toNum(event.value);
					
					var boss_max = event.item.boss_weight_rate;
					var mng_max = event.item.mng_weight_rate;
					
					for(var i=0;i<columnDataList.length;i++){
						if(event.dataField == columnDataList[i].incen_eval_cd_column && columnDataList[i].auto_cal_yn == 'N'){
							if(event.value == "" || event.value == event.oldValue){
								return event.oldValue;
							}
							
							if(columnDataList[i].incen_eval_cd != "0301" && columnDataList[i].incen_eval_cd != "0302" && columnDataList[i].incen_eval_cd != "0303"){
								if(event.value > columnDataList[i].weight_rate){
									setTimeout(function () {
	                                    AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "설정된 비중인 "+columnDataList[i].weight_rate+"를 넘을 수 없습니다.");
	                                }, 1);
									return event.oldValue;
								}
							}else{
								if(columnDataList[i].incen_eval_cd == "0301"){
									if(event.value > event.item.boss_weight_rate){
										setTimeout(function () {
		                                    AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "설정된 비중인 "+event.item.boss_weight_rate+"를 넘을 수 없습니다.");
		                                }, 1);
										return event.oldValue;
									}
								}else if(columnDataList[i].incen_eval_cd == "0302"){
									if(event.value > event.item.mng_weight_rate){
										setTimeout(function () {
		                                    AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "설정된 비중인 "+event.item.mng_weight_rate+"를 넘을 수 없습니다.");
		                                }, 1);
										return event.oldValue;
									}
								}else{
									var last_max = $M.toNum(event.item.last_weight_rate);
									if(event.item.boss_mem_no == ""){
										last_max += $M.toNum(boss_max);
									}
									if(event.item.mng_mem_no == ""){
										last_max += $M.toNum(mng_max);
									}
									if(event.value > last_max){
										setTimeout(function () {
		                                    AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "설정된 비중인 "+last_max+"를 넘을 수 없습니다.");
		                                }, 1);
										return event.oldValue;
									}
								}
							}
							
							var temp = {};
							temp[columnDataList[i].incen_eval_cd_column+"eval_yn"] = 'Y'
							if(event.item.eval_yn == 'Y'){
								temp.total_point =  new_total_point - event.oldValue;
							}else{
								temp.total_point =  new_total_point + event.item.total_auto_point - event.oldValue;
							}
							
							if(event.item.last_total_dt != ""){
								temp.last_total_point = temp.total_point + $M.toNum(event.item.rep_adjust_point);
							}
							
	                        AUIGrid.updateRow(auiGrid, {eval_yn: "Y"}, event.rowIndex);
	                        AUIGrid.updateRow(auiGrid, temp, event.rowIndex);
	                        
	                        if(columnDataList[i].incen_eval_cd == "0301"){
		                        AUIGrid.updateRow(auiGrid, {boss_eval_dt: '${inputParam.s_current_dt}'}, event.rowIndex);
	                        }else if(columnDataList[i].incen_eval_cd == "0302"){
		                        AUIGrid.updateRow(auiGrid, {mng_eval_dt: '${inputParam.s_current_dt}'}, event.rowIndex);
	                        }else if(columnDataList[i].incen_eval_cd == "0303"){
		                        AUIGrid.updateRow(auiGrid, {last_eval_dt: '${inputParam.s_current_dt}'}, event.rowIndex);
	                        }
	                        break;
						}
					}
					
					if(event.dataField == "rep_adjust_point"){
						console.log(event);
						if(event.value == "" || event.oldValue == event.value){
							return event.oldValue;
						}
						
						if(event.item.eval_yn == 'N'){
							AUIGrid.updateRow(auiGrid, {total_point: $M.toNum(event.item.total_auto_point)}, event.rowIndex);
						}
                        AUIGrid.updateRow(auiGrid, {eval_yn: "Y"}, event.rowIndex);
                        AUIGrid.updateRow(auiGrid, {last_total_dt: '${inputParam.s_current_dt}'}, event.rowIndex);
                        AUIGrid.updateRow(auiGrid, {last_total_point : $M.toNum(event.item.total_point) + $M.toNum(event.value)}, event.rowIndex);
					}
					break;
			}
		}
		
		
		// 그리드 스타일 설정 함수
		function myStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField){
			var secureUser = $M.getValue("secure_mem_no");
			for(var i=0; i<columnDataList.length; i++){
				if(headerText == columnDataList[i].incen_eval_name && columnDataList[i].auto_cal_yn == 'N'){
					if(columnDataList[i].incen_eval_cd == "0301"){
						if(secureUser == item.boss_mem_no){
							return "aui-center";
						}
						return "aui-background-darkgray";
					}else if(columnDataList[i].incen_eval_cd == "0302"){
						if(secureUser == item.mng_mem_no && item.mng_eval_yn == 'Y'){
							return "aui-center";
						}
						return "aui-background-darkgray";
					}else if(columnDataList[i].incen_eval_cd == "0303"){
						if(secureUser == item.last_mem_no){
							return "aui-center";
						}
						return "aui-background-darkgray";
					}
					
					if(secureUser == item.boss_mem_no || secureUser == item.mng_mem_no || secureUser == item.last_mem_no || secureUser == item.last_mem_no || "${page.fnc.F03120_002}" == "Y"){
						return "aui-center";
					}
					
					return "aui-background-darkgray";
				}
			}
			
			if(headerText == "대표조정"){
				if("${page.fnc.F03120_002}" == "Y"){
					return "aui-center";
				}
				return "aui-background-darkgray";
			}
		}
		
		// 검색
		function goSearch(){
		 	var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
	        if(changeGridData.length != 0){
	        	var check = confirm("조회시 입력한 내용이 사라집니다. 조회하시겠습니까?");
	        	if(!check){
	        		return;
	        	}
	        }

		 	var params = {
					"s_incen_year" : $M.getValue("s_incen_year"),
					"s_incen_grp_seq" : $M.getValue("s_incen_grp_seq"),
					"s_org_code" : $M.getValue("s_org_code"),
					"s_mem_name" : $M.getValue("s_mem_name"),
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : 'get'},
				function(result) {
					if(result.success) {
						$M.setValue("now_incen_year",$M.getValue("s_incen_year"));
						$("#calc_date").html(result.calcDate);
						columnDataList = result.columnList;
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.changeColumnLayout(auiGrid, getResultLayout(result));

                     	// 펼치기 전에 접힐 컬럼 목록
            			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
            			for (var i = 0; i <auiColList.length; ++i) {
            				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
            					dataFieldName.push(auiColList[i].dataField);
            				}
            			}
            			
            		 	var foldCheck = $("input:checkbox[id='s_toggle_column']").is(":checked");
            		 	
            			if(!foldCheck) {
            				for (var i = 0; i < dataFieldName.length; ++i) {
                				var dataField = dataFieldName[i];
                				AUIGrid.hideColumnByDataField(auiGrid, dataField);
                			}
            			}
            			
            			$("#auiGrid").resize();
                        AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 저장
		function goSave(){
	        var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
	        
	       	if(changeGridData.length == 0){
	       		alert("변경된 내용이 없습니다.");
	       		return ;
	       	}
	        var frm = document.main_form;
	 		var gridFrm = fnChangeGridDataToForm(auiGrid);

	 		$M.copyForm(gridFrm, frm);
	 		$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'POST'},
	 			function(result){
	 				if(result.success){
	 					AUIGrid.resetUpdatedItems(auiGrid);
	 					goSearch();
	 				}
	 			}
	 		);
		}
		
		// 조회시 컬럼 변경
		function getResultLayout(result){
			var columnLayout = [
				{
					headerText : "인센티브평가번호", 
					dataField : "incen_eval_seq", 
					visible : false,
				},
				{
					headerText : "그룹번호", 
					dataField : "incen_grp_seq", 
					visible : false,
				},
				{
					headerText : "직원번호", 
					dataField : "mem_no", 
					visible : false,
				},
				{
					headerText : "조직코드", 
					dataField : "org_code", 
					visible : false,
				},
				{
					headerText : "직위코드", 
					dataField : "grade_cd", 
					visible : false,
				},
				{
					headerText : "직책코드", 
					dataField : "job_cd", 
					visible : false,
				},
				{
					headerText : "평가년도", 
					dataField : "incen_year", 
					visible : false,
				},
				{
					headerText : "상사", 
					dataField : "boss_mem_no", 
					visible : false,
				},
				{
					headerText : "상사평가일자", 
					dataField : "boss_eval_dt", 
					visible : false,
				},
				{
					headerText : "매니저", 
					dataField : "mng_mem_no", 
					visible : false,
				},
				{
					headerText : "매니저평가대상", 
					dataField : "mng_eval_yn", 
					visible : false,
				},
				{
					headerText : "매니저평가일자", 
					dataField : "mng_eval_dt", 
					visible : false,
				},
				{
					headerText : "최종평가자", 
					dataField : "last_mem_no", 
					visible : false,
				},
				{
					headerText : "최종평가자평가일자", 
					dataField : "last_eval_dt", 
					visible : false,
				},
				{
					headerText : "상사평가비중", 
					dataField : "boss_weight_rate", 
					visible : false,
				},
				{
					headerText : "매니저평가비중", 
					dataField : "mng_weight_rate", 
					visible : false,
				},
				{
					headerText : "최종평가비중", 
					dataField : "last_weight_rate", 
					visible : false,
				},
				{
					headerText : "평가여부", 
					dataField : "eval_yn", 
					visible : false,
				},
				{
					headerText : "그룹", 
					dataField : "group_name", 
					style : "aui-center",
					width : "100",
					minWidth : "70",
					editable : false,
				},
				{
					headerText : "부서", 
					dataField : "org_name", 
					style : "aui-center",
					width : "100",
					minWidth : "70",
					editable : false,
				},
				{
					headerText : "직원명", 
					dataField : "mem_name", 
					style : "aui-center",
					width : "70",
					minWidth : "50",
					editable : false,
				},
			];
			var check = true;
			var columnList = result.columnList;
			if(columnList != null){
				for(var i=0; i<columnList.length; i++){
					var col;
					
					if(columnList[i].auto_cal_yn == "Y"){
						col = {
								headerText : columnList[i].incen_eval_name, 
								dataField : columnList[i].incen_eval_cd_column, 
								headerStyle : "aui-fold",
								style : "aui-background-darkgray",
								width : "100",
								editable : false,
								minWidth : "70",
								editRenderer: {
			                        type: "InputEditRenderer",
			                        onlyNumeric: true
			                    },
								labelFunction : function(rowIndex, columnIndex, value, headerText, item){
									if(value == 0){
										return "";
									}
									return value;
								}
						};
					}else{
						col = {
								headerText : columnList[i].incen_eval_name, 
								dataField : columnList[i].incen_eval_cd_column, 
								styleFunction : myStyleFunction,
								width : "100",
								editable : true,
								minWidth : "70",
								editRenderer: {
			                        type: "InputEditRenderer",
			                        onlyNumeric: true
			                    },
								labelFunction : function(rowIndex, columnIndex, value, headerText, item){
									if(value == 0){
										return "";
									}
									return value;
								}
						};

						var col2 = {
								dataField : columnList[i].incen_eval_cd_column+"eval_yn",
								visible: false,
						}
						columnLayout.push(col2);
						
						if(check){
							var temp = {
								headerText : "자동계산합계", 
								dataField : "total_auto_point", 
								style : "aui-background-darkgray",
								width : "90",
								minWidth : "50",
								editable : false,
								labelFunction : function(rowIndex, columnIndex, value, headerText, item){
									if(value == 0){
										return "";
									}
									return value;
								}
							};
							columnLayout.push(temp);
						}
						check = false;
					}
					
					columnLayout.push(col);

				}
			}
			
			var col = {
				headerText : "총점", 
				dataField : "total_point", 
				style : "aui-background-darkgray",
				width : "70",
				minWidth : "50",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item){
					if(value == 0 && item.eval_yn == 'N'){
						return item.total_auto_point;
					}
					return value;
				}
			};

			columnLayout.push(col);
			
			col = {
					headerText : "대표조정", 
					dataField : "rep_adjust_point", 
					styleFunction : myStyleFunction,
					width : "70",
					minWidth : "50",
					editable : true,
					editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: false
                    },
					labelFunction : function(rowIndex, columnIndex, value, headerText, item){
						if(value == 0 && item.last_total_dt == ""){
							return "";
						}
						return value;
					}
			};

			columnLayout.push(col);
			
			col = {
					headerText : "최종평점", 
					dataField : "last_total_point", 
					style : "aui-background-darkgray",
					width : "70",
					minWidth : "50",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item){
						if(item.last_total_dt == ""){
							return "";
						}
						return value;
					}
			};
			

			columnLayout.push(col);
			
			col = {
					headerText : "최종평가일자", 
					dataField : "last_total_dt", 
					style : "aui-background-darkgray",
					width : "90",
					minWidth : "50",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : false,
			};
			
			columnLayout.push(col);
			
			return columnLayout;
		}
		
		// 연도 변경시 그룹선택 변경
		function changeSelectList(sYear){
			var param = {
					"s_incen_year" : sYear
			}
			
			$M.goNextPageAjax(this_page + "/group", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("select#s_incen_grp_seq option").remove();
						var option = "";
						$("#s_incen_grp_seq").append(option);
						for(var i=0; i < result.list.length; i++){
							var temp = result.list[i];
							option = "<option value="+temp.incen_grp_seq+">"+temp.group_name+"</option>";
							$("#s_incen_grp_seq").append(option);
						}
					};
				}
			);
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "인센티브평가", exportProps);
		}
		
		function goSyncData(){
			var param = {
					"s_incen_year":$M.getValue("now_incen_year"),
			};

			$M.goNextPageAjaxMsg("자동계산 재생성을 하시겠습니까?",this_page +"/calc", $M.toGetParam(param), {method : 'POST'},
				function(result){
					$("#calc_date").html(result.calc_date);
				}
			);	
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="now_incen_year" name="now_incen_year" value=""/>
<input type="hidden" id="secure_mem_no" name="secure_mem_no" value="${SecureUser.mem_no }"/>
<input type="hidden" id="weight_rate" name="weight_rate" value=""/>
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="65px">
                                <col width="80px">
                                <col width="40px">
                                <col width="100px">
                                <col width="40px">
                                <col width="100px">
                                <col width="50px">
                                <col width="80px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년도</th>
                                <td>
<!--                                     <div class="form-row inline-pd"> -->
<!--                                         <div class="col-auto"> -->
<!--                                             <select class="form-control" id="s_incen_year" name="s_incen_year"> -->
<%--                                                 <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1"> --%>
<%--                                                     <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/> --%>
<%--                                                     <option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option> --%>
<%--                                                 </c:forEach> --%>
<!--                                             </select> -->
<!--                                         </div> -->
<!--                                     </div> -->
									<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="year_name" value="s_incen_year"/>
										<jsp:param name="sort_type" value="d"/>
									</jsp:include>
                                </td>
                                <th>그룹</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <select id="s_incen_grp_seq" name="s_incen_grp_seq" class="form-control">
                                                <option value=""> - 전체 - </option>
                                                <c:forEach items="${groupList}" var="item">
                                                    <option value="${item.incen_grp_seq}">${item.group_name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>부서</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <select id="s_org_code" name="s_org_code" class="form-control">
                                                <option value="">- 전체 -</option>
                                                <c:forEach items="${list}" var="item">
                                                    <option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected</c:if> >${item.org_name}</option>
                                                </c:forEach>
                                                <c:forEach var="list" items="${codeMap['WAREHOUSE']}">
                                                    <c:if test="${list.code_value ne '6000' and list.code_v2 eq 'Y'}">
                                                        <option value="${list.code_value}" <c:if test="${list.code_value eq SecureUser.org_code}">selected</c:if> >${list.code_name}</option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>직원명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                            	자동계산일시 : <span id="calc_date" name="calc_date">${calcDate}</span>
                           		<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">자동계산상세
								</label>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
                           	총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>