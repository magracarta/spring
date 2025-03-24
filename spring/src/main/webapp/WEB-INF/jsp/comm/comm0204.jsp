<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 전산 Q&A > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-03-12 11:53:52
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var oldRadioId;				// 기존 체크한 라디오 ID
		var oldRadioCheck = false;  // 기존 라디오 체크여부

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
// 			fnInit();

			$(document).on("click", "input[type=radio]", function(e) {
				var newRadioCheck   = $('input:radio[name="s_tag_match_yn"]').is(':checked'); // 라디오 체크 여부
				var newRadioId    	= $(this).attr('id');	// 체크한 라디오 ID

				if(oldRadioCheck == newRadioCheck) {
					// 이미 체크한 라디오박스 일 때 체크해제
					$("input:radio[id='" + oldRadioId + "']").prop("checked", false);
					oldRadioCheck = false;
				} else {
					// 라디오박스 체크여부 담기
					oldRadioCheck = newRadioCheck;
				};
				// 체크한 radio ID 담기
				oldRadioId = newRadioId;
			});
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_bbs_seq", "s_title", "s_content", "s_reg_mem_name", "s_bbs_cate_cd", "s_bbs_proc_cd", "s_bbs_charge_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function goSearch() {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_bbs_seq" : $M.getValue("s_bbs_seq"),
				"s_title" : $M.getValue("s_title"),
				"s_content" : $M.getValue("s_content"),
				"s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
				"s_bbs_cate_cd" : $M.getValue("s_bbs_cate_cd"),
				"s_bbs_proc_cd" : $M.getValue("s_bbs_proc_cd"),
				"s_cust_comp_yn" : $M.getValue("s_cust_comp_yn"),
				"s_sort_key" : "reg_date",
				"s_sort_method" : "desc",
				"s_bbs_charge_name" : $M.getValue("s_bbs_charge_name"),
				"s_tag_cd_str" : $M.getValue("s_tag_cd"),
				"s_tag_match_yn" : $M.getValue("s_tag_match_yn")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, []);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "bbs_seq",
				height: 555,
				showRowNumColumn: false,
				treeColumnIndex: 0,
				displayTreeOpen: true,
				enableFilter: true,
				filterLayerWidth: 700,
				filterLayerHeight: 400
			};
			var columnLayout = [
				{
					headerText: "게시판번호",
					dataField: "bbs_seq",
					width: "65",
					minWidth: "50",
					style: "aui-center",
					editable: false,

				},
				{
					headerText: "메뉴구분",
					dataField: "bbs_cate_name",
					width: "60",
					minWidth: "60",
					style: "aui-center",
					editable: false,
				},
				{
					dataField: "bbs_cate_cd",
					visible: false

				},
				{
					headerText: "제목",
					dataField: "title",
					width: "355",
					minWidth: "300",
					style: "aui-left aui-popup",
					editable: false,
				},
// 				{
// 					headerText : "답변여부", 
// 					dataField : "answer_yn",
// 					width : "75",
// 					minWidth : "75",
// 					style : "aui-center",
// 					editable : false,
// 					renderer : {
// 						type : "TemplateRenderer"
// 					},
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						if(item["answer_yn"] == "Y") {
// 							var answer = "답변 있음";
// // 							var template = '<div>' + '<span style="color:black";>' + answer + '</span>' + '</div>';
// // 							return template;
// 						} else {
// 							var answer = "";
// // 						    var template = '<div>' + '<span style="color:black";>' + answer + '</span>' + '</div>';
// 						}
// 						    return answer;
// 					}
// 				},
				{
					headerText: "고객담당자",
					dataField: "reg_mem_name",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					editable: false,
				},
				{
					headerText: "개발담당자1",
					dataField: "bbs_charge_name1",
					width: "85",
					minWidth: "60",
					style: "aui-center",
					editable: false,
				},
				{
					headerText: "개발담당자2",
					dataField: "bbs_charge_name2",
					width: "85",
					minWidth: "60",
					style: "aui-center",
					editable: false,
				},
				{
					headerText: "태그",
					dataField: "bbs_tag_name",
					width: "130",
					minWidth: "100",
					style: "aui-center",
					editable: false,
					filter: {
						showIcon: true
					},
				},
				{
					headerText: "작성시간",
					dataField: "reg_date",
					width : "120",
					minWidth : "120",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss", 
					style : "aui-center",
					editable : false,
				},
				// {
				// 	headerText : "작성시간", 
				// 	dataField : "reg_date", 
				// 	width : "75",
				// 	minWidth : "70",
				// 	dataType : "date",
				// 	formatString : "HH:MM:ss", 
				// 	style : "aui-center",
				// 	editable : false,
				// },
				{
					headerText: "최종수정시간",
					dataField: "last_upt_date",
					width : "190",
					minWidth : "180",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return AUIGrid.formatDate(value, "yy-mm-dd HH:MM:ss")  + " (" + item["last_mem_name"] + ")";
					}
				},
				{
					dataField: "last_mem_name",
					visible: false
				},
				{
					headerText : "완료요청일", 
					dataField : "reser_comp_dt", 
					width : "75",
					minWidth : "70",
					dataType : "date",
					formatString : "yy-mm-dd", 
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "조치예정일", 
					dataField : "reser_dev_dt", 
					width : "75",
					minWidth : "70",
					dataType : "date",
					formatString : "yy-mm-dd", 
					style : "aui-center",
					editable : false,
				},
// 				{
// 					headerText : "담당자", 
// 					dataField : "bbs_charge_name", 
// 					width : "95",
// 					minWidth : "70",
// 					style : "aui-center",
// 					editable : false,
// 				},
				{
					headerText : "최종완료일", 
					dataField : "cust_comp_dt",
					width: "75",
					minWidth: "70",
					dataType: "date",
					formatString: "yy-mm-dd",
					style: "aui-center",
					editable: false,
				},
				{
					headerText: "상태",
					dataField: "bbs_proc_name",
					width: "70",
					minWidth: "55",
					style: "aui-center",
					editable: false,
				},
// 				{
// 					headerText : "고객확인날짜", 
// 					dataField : "cust_comp_dt", 
// 					width : "80",
// 					minWidth : "80",
// 					dataType : "date",
// 					formatString : "yy-mm-dd", 
// 					style : "aui-center",
// 					editable : false,
// 				},
				{
					dataField : "bbs_proc_cd", 
					visible : false
				},
				{
					dataField: "org_code",
					visible: false
				},
				{
					dataField: "org_name",
					visible: false
				},
				{
					headerText: "조회수",
					dataField: "read_cnt",
					width: "45",
					minWidth: "45",
					style: "aui-center",
					editable: false
				},
				<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
					{
						headerText: "작업공수",
						dataField: "work_hour",
						dataType : "numeric",
						width: "60",
						minWidth: "60",
						style: "aui-center",
						editable: false
					},
				</c:if>
				{
					dataField: "bbs_depth",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var frm = document.main_form;
				if(event.dataField == "title") {
					var param = {
						"bbs_seq" : event.item["bbs_seq"]
// 						"org_code" : event.item["org_code"],
// 						"org_name" : event.item["org_name"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=925, left=0, top=0";
					$M.goNextPage('/comm/comm0204p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
		
		// 문의하기 페이지 이동
		function goNew() {
			$M.goNextPage("/comm/comm020401");
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "전산Q&A", exportProps);
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
						<table class="table table-fixed">
							<colgroup>
								<col width="80px">
								<col width="90px">
								<col width="80px">
								<col width="90px">
								<col width="80px">
								<col width="120px">
								<col width="80px">
								<col width="120px">
								<col width="80px">
								<col width="120px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>작성일자</th>
									<td colspan="3">
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="작성시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="작성종료일">
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
									<th colspan="">게시판번호</th>
									<td>
										<input type="text" class="form-control width140px" id="s_bbs_seq" name="s_bbs_seq" placeholder="입력시 다른조건 무시">
									</td>									
									<th>제목</th>
									<td>
										<input type="text" class="form-control width140px" id="s_title" name="s_title">
									</td>
									<th>태그</th>
									<td colspan="2">
										<input class="form-control" style="width: 99%;" type="text" id="s_tag_cd" name="s_tag_cd" easyui="combogrid"
											   easyuiname="tagList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="s_tag_match_n" name="s_tag_match_yn" value="N">
											<label class="form-check-label pr10" for="s_tag_match_n">포함</label>
											<input class="form-check-input" type="radio" id="s_tag_match_y" name="s_tag_match_yn" value="Y">
											<label class="form-check-label" for="s_tag_match_y">일치</label>
										</div>
									</td>
									<!-- 									<th>내용</th> -->
									<!-- 									<td colspan="3"> -->
									<!-- 										<input type="text" class="form-control width140px" id="s_content" name="s_content"> -->
									<!-- 									</td> -->
								</tr>
								<tr>
									<th>고객담당자</th>
									<td colspan="">
										<input type="text" class="form-control width120px" id="s_reg_mem_name"
											   name="s_reg_mem_name">
									</td>
									<th colspan="">개발담당자1,2</th>
									<td colspan="">
										<input type="text" class="form-control width120px" id="s_bbs_charge_name"
											   name="s_bbs_charge_name">
									</td>
									<th>구분</th>
									<td>
										<select class="form-control width140px" id="s_bbs_cate_cd" name="s_bbs_cate_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['BBS_CATE']}">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" id="s_bbs_proc_cd" name="s_bbs_proc_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['BBS_PROC']}">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
											<option value="Y">개발완료 제외</option>
											<c:if test="${page.fnc.F00463_001 eq 'Y'}"><option value="YY">완료,협의 제외</option></c:if>
										</select>
									</td>
									<th colspan="">고객검수여부</th>
									<td>
										<select class="form-control" id="s_cust_comp_yn" name="s_cust_comp_yn">
											<option value="">- 전체 -</option>
											<option value="Y"> 검수 </option>
											<option value="N"> 미검수 </option>
										</select>
									</td>
									<td colspan="2">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
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