<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 시상관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-04-28 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var memAwardJson = JSON.parse('${codeMapJsonObj['MEM_AWARD']}');
	var auiGrid;
	var totalCnt = 0;
	var gridRowIndex;
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		goSearch();
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
				dataField : "seq_no",
				visible : false
			},
			{
				dataField : "mem_no",
				visible : false
			},
			{
				headerText: "부서",
				dataField: "org_name",
				width : "120",
				style : "aui-center aui-editable",
				editable : false,
			},
			{
				headerText: "직원명",
				dataField: "mem_name",
				width : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "직책",
				dataField: "grade_name",
				width : "90",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "직급",
				dataField: "job_name",
				width : "90",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "계정아이디",
				dataField: "web_id",
				width : "120",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "사번",
				dataField: "emp_id",
				width : "120",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "시상일자",
				dataField: "award_dt",
				width : "100",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				style : "aui-center aui-editable",
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
				}
			},
			{
				headerText: "시상구분",
				dataField: "mem_award_cd",
				width : "100",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : memAwardJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<memAwardJson.length; i++){
						if(value == memAwardJson[i].code_value){
							return memAwardJson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "비고",
				dataField: "remark",
				width : "350",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							totalCnt--;
							$("#total_cnt").html(totalCnt);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							totalCnt++;
							$("#total_cnt").html(totalCnt);
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : true
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		// 직원조회 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if(event.dataField == "org_name") {
				console.log("event : ", event);
				gridRowIndex = event.rowIndex;
				param = {
					  "agency_yn" : "N"
				}									
				openMemberOrgPanel('fnsetOrgMapPanel', "N" , $M.toGetParam(param));
			}
		});
	}
	
	// 직원조회 후 결과 세팅
	function fnsetOrgMapPanel(data) {
		AUIGrid.updateRow(auiGrid, { "org_name" : data.org_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "mem_name" : data.mem_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "mem_no" : data.mem_no }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "grade_name" : data.grade_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "job_name" : data.job_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "web_id" : data.web_id }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "emp_id" : data.emp_id }, gridRowIndex);
	}
	
	function goSearch() {
		var param = {
				"s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
				"s_start_year" : $M.getValue("s_start_year") + "0101",
				"s_end_year" : $M.getValue("s_end_year") + "1231",
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_mem_award_cd" : $M.getValue("s_mem_award_cd"),
				"s_org_code" : $M.getValue("s_org_code")
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
					
					totalCnt = result.total_cnt;
				};
			}		
		);	
	}
	
	function goSave() {
        var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
        var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
        var removeGridData = AUIGrid.getRemovedItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0 && removeGridData == 0) {
			alert("변경된 내역이 없습니다.");
			return;
		}
        
        if (fnCheckGridEmpty() == false) {
        	return;
        }
		
		var memNoArr = [];
		var seqNoArr = [];
		var awardDtArr = [];
		var memAwardCdArr = [];
		var remarkArr = [];
		var cmdArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			memNoArr.push(addGridData[i].mem_no);
			seqNoArr.push(addGridData[i].seq_no);
			awardDtArr.push(addGridData[i].award_dt);
			memAwardCdArr.push(addGridData[i].mem_award_cd);
			remarkArr.push(addGridData[i].remark);
			cmdArr.push("C");
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			memNoArr.push(changeGridData[i].mem_no);
			seqNoArr.push(changeGridData[i].seq_no);
			awardDtArr.push(changeGridData[i].award_dt);
			memAwardCdArr.push(changeGridData[i].mem_award_cd);
			remarkArr.push(changeGridData[i].remark);
			cmdArr.push("U");
		}
		
		for (var i = 0; i < removeGridData.length; i++) {
			memNoArr.push(removeGridData[i].mem_no);
			seqNoArr.push(removeGridData[i].seq_no);
			awardDtArr.push(removeGridData[i].award_dt);
			memAwardCdArr.push(removeGridData[i].mem_award_cd);
			remarkArr.push(removeGridData[i].remark);
			cmdArr.push("D");
		}

		var option = {
				isEmpty : true
		};
		
		var param = {
				mem_no_str : $M.getArrStr(memNoArr, option),
				seq_no_str : $M.getArrStr(seqNoArr, option),
				award_dt_str : $M.getArrStr(awardDtArr, option),
				mem_award_cd_str : $M.getArrStr(memAwardCdArr, option),
				remark_str : $M.getArrStr(remarkArr, option),
				cmd_str : $M.getArrStr(cmdArr, option),
		}
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);	
	}
	
	// 행추가
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.org_name = "",
    		item.mem_name = "",
    		item.grade_name = "",
    		item.job_name = "",
    		item.web_id = "",
    		item.emp_id = "",
    		item.award_dt = "",
    		item.mem_award_cd = "",
    		item.remark = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
			totalCnt++;
			$("#total_cnt").html(totalCnt);
		}	
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["org_name", "award_dt", "mem_award_cd"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 엑셀 다운로드
	function fnDownloadExcel() {
	  // 엑셀 내보내기 속성
	  var exportProps = {};
	  fnExportExcel(auiGrid, "시상관리", exportProps);
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
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
                                <col width="180px">
                                <col width="40px">
                                <col width="100px">
                                <col width="60px">
                                <col width="100px">
                                <col width="65px">
                                <col width="100px">
                                <col width="110px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>조회년도</th>	
                                    <td>
	                                    <div class="form-row inline-pd">
	                                        <div class="col-auto">
												<select class="form-control" id="s_start_year" name="s_start_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year-1}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
	                                        </div>
	                                        <div class="col-auto text-center">~</div>
	                                        <div class="col-auto">
												<select class="form-control" id="s_end_year" name="s_end_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
	                                        </div>
	                                    </div>
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
                                    <th>직원명</th>
                                    <td>    
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>		
                                    <th>시상구분</th>
                                    <td>    
										<select class="form-control" id="s_mem_award_cd" name="s_mem_award_cd">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MEM_AWARD']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
										</div>
                                    </td>						
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
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
					<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
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
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>