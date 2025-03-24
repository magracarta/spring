<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 기안문서 > 출장여비정산서 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* 스타일이 겹쳐서 aui_status 스타일과 aui-editable 스타일을 합침 */
		.proc_style {
			background-color : #eee;
			color : blue;
			cursor: pointer;
		}
	</style>	
	
	<script type="text/javascript">
	
	var auiGrid;
	var gridRowIndex;
	
	$(document).ready(function() {
		if ( parent.fnStyleChange )
			parent.fnStyleChange('search');
		
		// 그리드 생성
		if ("${inputParam.init_yn}" == "Y") {
			createAUIGrid();
			goSearch();
		}
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "doc_no",
				visible : false
			},
			{
				dataField : "appr_proc_status_cd",
				visible : false
			},
			{
				headerText: "작성일",
				dataField: "doc_dt",
				width : "70",
				style : "aui-center",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				editable : false,
			},
			{
				headerText: "출장구분",
				dataField: "trip_io_name",
				width : "60",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "부서",
				dataField: "org_name",
				width : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "작성자",
				dataField: "mem_name",
				width : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "출장지(국)",
				dataField: "trip_place",
				width : "150",
				style : "aui-left aui-popup",
				editable : false,
			},
			{
				headerText: "방문일",
				dataField: "visit_dt",
				width : "70",
				style : "aui-center",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				editable : false,
			},
			{
				headerText: "방문처",
				dataField: "visit_place",
				width : "150",
				style : "aui-left",
				editable : false,
			},
			{
				headerText: "내용",
				dataField: "visit_content",
				width : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText: "결재",
				dataField: "path_appr_job_status_name",
				width : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText: "지급일자",
				dataField: "proc_dt",
				width : "100",
				style : "aui-center",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				dataType : "date",   
				editable : true,
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if ('${page.fnc.F02012_001}' == 'Y' && item.aui_status_cd == 'C') {
						return "proc_style";
					} else {
						return null;
					}
				},
			},
			{
				headerText: "지급자",
				dataField: "proc_mem_name",
				width : "100",
				style : "aui-center",
				editable : false,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if ('${page.fnc.F02012_001}' == 'Y' && item.aui_status_cd == 'C') {
						return "proc_style";
					} else {
						return null;
					}
				},
			},
			{
				headerText : "지급취소",
				dataField : "calcel_proc",
				width : "80",
				minWidth : "80",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						AUIGrid.updateRow(auiGrid, {proc_dt : "", proc_mem_no : "", proc_mem_name : undefined}, event.rowIndex);
						if(event.item.proc_yn == "N") {
							AUIGrid.resetUpdatedItemById(auiGrid, event.item._$uid, "e");
						}
					},
					visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
						// 삭제버튼은 지급완료일 시만 보이도록
						if(item.proc_dt != "" && item.proc_mem_no != "") {
							return true;
						} else {
							return false;
						}
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '취소'
				},
				style : "aui-center",
				editable : false
			},
			{
				dataField: "proc_mem_no",
				visible : false
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		if ('${page.fnc.F02012_001}' != 'Y') {
			AUIGrid.hideColumnByDataField(auiGrid, ["calcel_proc"]);
		}
		$("#auiGrid").resize();
		
		// 관리부만 수정 가능.
		AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {
			if (event.item.appr_proc_status_cd != '05') {
				if(event.dataField == "proc_dt" || event.dataField == "proc_mem_name" ) {
					return false; 
				}
			}
			
			if('${page.fnc.F02012_001}' != 'Y') {
				if(event.dataField == "proc_dt" || event.dataField == "proc_mem_name" ) {
					return false; 
				}	
			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
			// 지급자 입력하지않고, 지급일자 입력시 지급자 자동세팅.						
			if (event.dataField == "proc_dt") {
				if (event.item.proc_mem_no == "") {
				    AUIGrid.updateRow(auiGrid, { "proc_mem_name" : '${SecureUser.kor_name}' }, event.rowIndex);
				    AUIGrid.updateRow(auiGrid, { "proc_mem_no" : '${inputParam.login_mem_no}' }, event.rowIndex);
				}
			}
		});		
		
		// 직원조회 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if(event.dataField == "proc_dt" || event.dataField == "proc_mem_name" ) {
				if ('${page.fnc.F02012_001}' != 'Y') {
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "관리부만 입력 가능합니다.");
					}, 1);
					return false; 
				}
				
				if (event.item.appr_proc_status_cd != '05') {
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "결재 완료 후 입력 가능합니다.");
					}, 1);
					return false; 
				}
			}
			
			if(event.dataField == "trip_place") {
				var param = {
					doc_no : event.item.doc_no
				};
					
				var popupOption = "";
				$M.goNextPage('/mmyy/mmyy011103p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
			
			// 관리부일경우에만 접근가능.
			if('${page.fnc.F02012_001}' == 'Y' && event.item.appr_proc_status_cd == '05') {
				if(event.dataField == "proc_mem_name") {
					gridRowIndex = event.rowIndex;
					param = {};										
					openSearchMemberPanel('fnSetMemInfo', $M.toGetParam(param));
				}	
			}
		});
	}	
	
	// 출장여비정산서 등록
	function goNew() {
		$M.goNextPage("/mmyy/mmyy01110301");
	}
	
	// 조회
	function goSearch() {
		var param = {
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_trip_io" : $M.getValue("s_trip_io"),
			"s_org_code" : $M.getValue("s_org_code"),
			"s_mem_name" : $M.getValue("s_mem_name"),
			"s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
			"s_mem_no" : $M.getValue("s_my_yn") == "Y" ? "${SecureUser.mem_no}" : "",
			"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd")
		};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);	
	}
	
	// 엑셀 다운로드
	function fnExcelDownload() {
	  // 엑셀 내보내기 속성
	  var exportProps = {};
	  fnExportExcel(auiGrid, "출장여비정산서", exportProps);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_mem_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	// 직원조회 결과
	function fnSetMemInfo(data) {		
	    AUIGrid.updateRow(auiGrid, { "proc_mem_name" : data.mem_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "proc_mem_no" : data.mem_no }, gridRowIndex);
	}
	
	// 저장
	function goSave() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		var docNoArr = [];
		var procDtArr = [];  // 지급일자
		var procMemNoArr = []; // 지급자
		
		for (var i = 0; i < changeGridData.length; i++) {
			docNoArr.push(changeGridData[i].doc_no);
			procDtArr.push(changeGridData[i].proc_dt);
			procMemNoArr.push(changeGridData[i].proc_mem_no);
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				doc_no_str : $M.getArrStr(docNoArr, option),
				proc_dt_str : $M.getArrStr(procDtArr, option),
				proc_mem_no_str : $M.getArrStr(procMemNoArr, option),
				all_yn : 'Y',
		}
		
		$M.goNextPageAjaxSave("/mmyy/mmyy0111/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);	
	}	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">		
<!-- 검색영역 -->					
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="65px">
                                <col width="260px">
                                <col width="60px">
                                <col width="100px">
                                <col width="40px">
                                <col width="100px">
                                <col width="55px">
                                <col width="100px">
                                <col width="55px">
                                <col width="100px">
                                <col width="110px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>작성일자</th>	
                                    <td>
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
												</div>
                                            </div>
                                            <div class="col-auto">~</div>
                                            <div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
												</div>
                                            </div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     	</jsp:include>	                                            
                                        </div>
                                    </td>                             
                                    <th>출장구분</th>
                                    <td>
										<select class="form-control" id="s_trip_io" name="s_trip_io">
											<option value="">- 선택 -</option>
											<option value="I">국내</option>
											<option value="O">해외</option>
										</select>
                                    </td>	
                                    <th>부서</th>
                                    <td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 선택 -</option>
											<c:forEach items="${orgList}" var="item">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
                                    </td>	
                                    <th>작성자</th>
                                    <td>    
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>	
                            		<th>상태</th>		
									<td>		
										<select class="form-control" id="s_appr_proc_status_cd" name="s_appr_proc_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['APPR_PROC_STATUS']}" var="item">
												<c:if test="${item.code_value ne '06'}">
													<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
												</c:if>
											</c:forEach>
											<option value="PROCY">지급완료</option>
											<option value="PROCN">미지급</option>
										</select>
									</td>                                       	
                                    <td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
										</div>
                                    </td>	
									<td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_my_yn"  name="s_my_yn" value="Y">
											<label class="form-check-label" for="s_my_yn">본인 건만 조회</label>
										</div>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
                        </div>		
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
					</div>				
				</div>
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>	
</body>
</html>