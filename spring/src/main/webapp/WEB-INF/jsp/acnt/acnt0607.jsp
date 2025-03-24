<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 발령관리 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2021-05-27 16:20:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	var auiGrid;

	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_mem_name"];
		$.each(field, function () {
			if (fieldObj.name == this) {
				goSearch();
			}
		});
	}
	
	// 발령등록
	function goNew() {
		$M.goNextPage('/acnt/acnt060701');
	}
	
	// 검색
	function goSearch() {
		if($M.checkRangeByFieldName('s_start_year', 's_end_year', true) == false) {				
			return;
		}; 
		var param = {
				"s_start_year": $M.getValue("s_start_year"),
				"s_end_year": $M.getValue("s_end_year"),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_name": $M.getValue("s_mem_name"),
				"s_mem_move_code": $M.getValue("s_mem_move_code"),
				"s_work_status_yn": $M.getValue("s_work_status_yn")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				}
		);
	}
	
	// 그리드 생성
	function createAUIGrid() {
		var gridPros = {
				rowIdField : "_$uid",
				// No. 생성
				showRowNumColumn: true,
			    // 트리 펼치기
				displayTreeOpen : true,
				rowCheckDependingTree : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true,
				rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
	               // 공지가 등록된 경우 체크 불가
	               if (item.modify_yn =='N') {
	                  return false;
	               }

	               return true;
		        },
				treeColumnIndex : 0
		};
		var columnLayout = [
			{
				headerText : "발령번호", 
				dataField : "mem_move_no", 
				width : "140",
				minWidth : "140",
				style : "aui-center",
				editable : false,
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(item.seq_no == -1){
						return value;
					}else{
						return "";
					}
				}
			},
			{
				headerText : "직원번호", 
				dataField : "temp_mem_no", 
				visible : false,
			},
			{
				headerText : "생년월일",
				dataField : "birth_dt",
				visible : false,
			},
			{
				headerText : "발령순번", 
				dataField : "seq_no", 
				visible : false,
			},
			{
				headerText : "직원명", 
				dataField : "kor_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center aui-popup",
				editable : false,
			},
			{
				headerText : "계정아이디", 
				dataField : "web_id", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사번", 
				dataField : "emp_id", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "발령일자", 
				dataField : "move_dt", 
				width : "70",
				minWidth : "70",
				dataType : "date",
				formatString : "yy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "발령구분코드", 
				dataField : "mem_move_cd",
				visible : false,
			},
			{
				headerText : "발령구분", 
				dataField : "mem_move_name", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "현 정보", 
				children:[
					{
						headerText : "부서", 
						dataField : "old_org_name", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						editable : false,
					},
					{
						headerText : "직책", 
						dataField : "old_grade_name", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						editable : false,
					},
				]
			},
			{
				headerText : "발령 후 정보", 
				children:[
					{
						headerText : "부서", 
						dataField : "new_org_name", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						editable : false,
					},
					{
						headerText : "직책", 
						dataField : "new_grade_name", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						editable : false,
					},
				]
			},
			{
				headerText : "시작일", 
				dataField : "start_dt", 
				width : "90",
				minWidth : "90",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "종료일", 
				dataField : "end_dt", 
				width : "90",
				minWidth : "90",
				dataType : "date",
				formatString : "yyyy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "비고", 
				dataField : "remark", 
				width : "150",
				minWidth : "150",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "공지여부", 
				dataField : "notice_seq", 
				width : "60",
				minWidth : "60",
				styleFunction : function(rowIndex, colunmIndex, value, item){
					if(value > 0){
						return "aui-popup";
					}else{
						return "aui-center";
					}
				},
				editable : false,
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(value == -1){
						return "";
					}else if(value == 0){
						return "N";
					}else{
						return "Y";
					}
				}
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			// 이름 클릭시 상세보기 팝업
			if(event.dataField=="kor_name"){
				param = {
						"mem_move_no":event.item.mem_move_no
				}
				var poppupOption = "";
				$M.goNextPage('/acnt/acnt0607p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}
			// 공지여부 클릭시 해당 공지 팝업
			if(event.dataField=="notice_seq"){
				if(event.item.notice_seq > 0){
					param = {
							"notice_seq" : event.item.notice_seq
					}
					var poppupOption = "";
					$M.goNextPage('/mmyy/mmyy0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			}
		});
	}
	
	// 체크 후 발령공지
	function goNoticeAppoint(){
		var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);

		if(checkedItems.length <= 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		}
		
		var frm = $M.createForm();
		var columns = fnGetColumns(auiGrid);
		
		for(var i = 0; i < checkedItems.length; i++){
			if(checkedItems[i].item.notice_seq != -1){
				frm = fnToFormData(frm, columns, checkedItems[i].item);
			}
		}

		$M.goNextPageAjaxMsg("발령공지하시겠습니까?",this_page + "/notice", frm , {method : 'POST'},
			function(result){
				if(result.success){
					goSearch();
				}
			}
		);
	}
	
	function goHRApply(){
		var param = {
				
		};

		$M.goNextPageAjaxMsg("공지된 발령사항을 인사정보에 반영하시겠습니까?", this_page + "/hrApply", $M.toGetParam(param), {method: "POST"},
				function (result) {
					if(result.success){
						goSearch();
					}
				}
		);
	}
	
	// 엑셀 다운로드
	function fnDownloadExcel() {
		var exportProps = {
		         // 제외항목
		  };
	  	fnExportExcel(auiGrid, "발령관리", exportProps);
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
	<!-- 기본 -->					
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="160px">
							<col width="50px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="100px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <select class="form-control" id="s_start_year" name="s_start_year">
                                                <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}"
														   step="1">
													<c:set var="year_option"
														   value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}"
															<c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년
													</option>
												</c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-auto"> ~ </div>
                                        <div class="col-auto">
                                            <select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}"
														   step="1">
													<c:set var="year_option"
														   value="${inputParam.s_current_year - i + 2000+1}"/>
													<option value="${year_option}"
															<c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년
													</option>
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
								<th>발령구분</th>
								<td>
									<select class="form-control" id="s_mem_move_code" name="s_mem_move_code">
										<option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['MEM_MOVE']}">
                                            <option value="${list.code_value}" >${list.code_name}</option>
                                        </c:forEach>
									</select>
								</td>
								<th>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y">
                                        <label class="form-check-label mr5" for="s_work_status_yn">퇴사자제외</label>
                                    </div>
                                </th>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>								
						</tbody>
					</table>
				</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>