<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 기준정보 > 앱버전관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-05-16 16:47:31
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();

			$M.setValue("s_use_yn", "Y");
			goSearch("new");
		});	
		
		function goSearch(isNew) {
			var param = {
					"s_device_type_cd" : $M.getValue("s_device_type_cd"),
					"s_use_yn" : $M.getValue("s_use_yn")
			}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							var list = result.list;
							AUIGrid.setGridData(auiGrid, list);
							$("#total_cnt").html(result.total_cnt);

							if (isNew != undefined) {
								fnSetData();
							}
						};
					}
			);
		}
		
		// 신규
		function fnNew() {
			fnSetData();
			$("#device_type_cd").focus();
		}
		
		// 저장
		function goSave() {
			var frm = document.main_form;

			if ($M.validation(frm) == false) {
				return false;
			};

			if ($M.getValue('file_comp') == "" && $M.getValue("url") == "") {
				alert("[URL경로, 첨부파일] 중 하나는 필수 입력입니다.");
				return false;
			}

			var url = this_page;

			if ($M.getValue(frm, "cmd") == "C") {
				url += "/save";
			} else {
				url += "/modify";
			}

			$M.goNextPageAjaxSave(url, frm, { method : 'POST'},
				function(result) {
					if(result.success) {
						$M.setValue("url", result.url);
						goSearch();
						fnRemoveFile();
					};
				}
			);
		}
		
		// 메인그리드
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				rowIdTrustMode: true,
				showRowNumColumn: true,
				wrapSelectionMove : false
			};
			var columnLayout = [
				{ 
					headerText : "디바이스 타입",
					dataField : "device_type_name",
					width : "20%",
					style : "aui-left",
					editable : false
				}, 
				{ 
					headerText : "버전",
					dataField : "app_ver",
					width : "18%",
					style : "aui-center",
					editable : false
				}, 
				{ 
					headerText : "URL 경로",
					dataField : "url",
					style : "aui-left",
					editable : false
				}, 
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "12%",
					style : "aui-center",
					editable : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var param = {
					cmd : "U",
					device_type_cd : event.item["device_type_cd"],
					app_ver : event.item["app_ver"],
					url: event.item["url"],
					use_yn : event.item["use_yn"]
				}
				fnSetData(param);
			});
		}

		function fnSetData(param) {
			fnRemoveFile();

			if (param == undefined || param == null) {
				param = {
					cmd : "C",
					device_type_cd : "",
					app_ver : "",
					url : "",
					use_yn : "Y"
				}
			}
			$M.setValue(param);

			var cmd = $M.getValue("cmd");
			if (cmd == "U") {
				$("#device_type_cd").attr("readonly", true);
				$("#device_type_cd").removeClass("essential-bg");
				$("#app_ver").attr("readonly", true);
				$("#app_ver").removeClass("essential-bg");
			} else {
				$("#device_type_cd").attr("readonly", false);
				$("#device_type_cd").addClass("essential-bg");
				$("#app_ver").attr("readonly", false);
				$("#app_ver").addClass("essential-bg");
			}
		}

		function goSearchFile() {
			var files = document.getElementById("file_comp").files;
			if (files.length > 0) {
				alert("파일은 한개만 업로드 가능합니다.");
			} else {
				$("#file_comp").click();
			}
		}

		// 파일 선택되면 실행
		function fnFileSelect() {
			var fileObj = document.getElementById("file_comp").files[0];

			//용량제한(무조건체크)
			var maxSize = 200000;
			var fileSize = Math.ceil(fileObj.size / 1024);	// kb환산
			if(maxSize < fileSize) {
				alert("파일 용량 제한이 있습니다.\n가능 용량 : " +  maxSize +"KB " +  "\n현재 파일용량 :  " + fileSize + "KB");
				return false;
			}

			fnPrintFile(0, fileObj.name);
		}

		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item app_file" style="float:left; display:block;">';
			str += '<a href="javascript:void(0);" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_name" value="' + fileName + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$(".att_file_div").append(str);

			$("#url").val("");
			$("#url").attr("readonly", true);
		}

		// 첨부파일 삭제
		function fnRemoveFile() {
			//input file 초기화
			var agent = navigator.userAgent.toLowerCase();
			if ((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1)) {
				$("#file_comp").replaceWith( $("#file_comp").clone(true) );
			}
			else {
				$("#file_comp").val("");
			}

			$(".app_file").remove();
			$("#url").attr("readonly", false);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form" enctype="multipart/form-data">
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
								<col width="80px">
								<col width="130px">
								<col width="70px">
								<col width="130px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
									<th>디바이스타입</th>
									<td>
										<select class="form-control" id="s_device_type_cd" name="s_device_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['DEVICE_TYPE']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>사용여부</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="">- 전체 -</option>
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch('new');">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->	
					<div class="row">
						<!-- 목록 -->
						<div class="col-7">
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
							</div>
							<div style="margin-top: 5px;" id="auiGrid"></div>
							<!-- 그리드 서머리, 컨트롤 영역 -->
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="total_cnt">0</strong>건 
								</div>						
							</div>
							<!-- /그리드 서머리, 컨트롤 영역 -->
						</div>
						<!-- /목록 -->
						<div class="col-5">
							<div class="row">
								<div class="col-12" style="padding-left : 10px;">
									<div class="title-wrap mt10">
										<h4>버전정보</h4>
									</div>							
									<!-- 폼테이블 -->	
									<div>
										<table class="table-border mt5">
											<colgroup>
												<col width="100px">
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">디바이스타입</th>
													<td>
														<select class="form-control essential-bg width140px" id="device_type_cd" name="device_type_cd" alt="디바이스타입" required="required">
															<option value="">- 선택 -</option>
															<c:forEach var="item" items="${codeMap['DEVICE_TYPE']}">
																<option value="${item.code_value}">${item.code_name}</option>
															</c:forEach>
														</select>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">버전</th>
													<td>
														<input type="text" class="form-control essential-bg width140px" id="app_ver" name="app_ver" alt="버전" required="required">
													</td>
												</tr>
												<tr>
													<th class="text-right">URL 경로</th>
													<td>
														<input type="text" class="form-control" id="url" name="url" alt="URL 경로">
													</td>
												</tr>
												<tr>
													<th class="text-right">첨부파일</th>
													<td>
														<div class="table-attfile att_file_div" style="width:100%;">
															<div class="table-attfile" style="float:left">
																<input type="file" name="file_comp" id="file_comp" style="display:none;width:5px;" onChange="javascript:fnFileSelect(this);" >
																<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:goSearchFile();">파일찾기</button>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y" alt="사용여부" required="required">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N" required="required">
															<label class="form-check-label">N</label>
														</div>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->
									<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
									<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
								<!-- /버튼정보 -->									
							</div>					
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